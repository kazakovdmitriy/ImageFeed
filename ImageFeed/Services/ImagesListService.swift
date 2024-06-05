//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий on 29.05.2024.
//

import Foundation

enum ImagesListServiceError: Error {
    case invalidPhotosRequest
    case invalidLikeRequest
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard
            let request = makeLikeRequest(photoId: photoId, isLike: isLike)
        else {
            completion(.failure(ImagesListServiceError.invalidLikeRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self = self else {
                print("Self is nil в changeLike")
                return
            }
            
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]
                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                    self.photos[index] = newPhoto
                }
                
                completion(.success(()))
                
            case .failure(let failure):
                print("[ImagesListService]: \(failure.localizedDescription)")
                completion(.failure(failure))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        fetchPhotos(page: nextPage) { result in
                        
            switch result {
            case .success(_):
                print("Photo loaded success")
            case .failure(let error):
                print("[ImagesListService]: \(error.localizedDescription)")
            }
            
        }
    }
    
    func clean() {
        photos = []
    }
    
    private func fetchPhotos(page: Int, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)

        task?.cancel()
        
        guard
            let request = makeImageListRequest(page: page)
        else {
            completion(.failure(ImagesListServiceError.invalidPhotosRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let result):
                self.lastLoadedPage = page
                
                result.forEach {
                    self.photos.append(self.convertResultToPhoto(result: $0))
                }
                
                completion(.success(self.photos))
                
                NotificationCenter.default
                    .post(name: ImagesListService.didChangeNotification,
                          object: self,
                          userInfo: ["photos": self.photos])
                
            case .failure(let failure):
                print("[ImagesListService]: \(failure.localizedDescription)")
                completion(.failure(failure))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func convertResultToPhoto(result: PhotoResultElement) -> Photo {
        return Photo(id: result.id,
                     size: CGSize(width: result.width, height: result.height),
                     createdAt: result.createdAt,
                     welcomeDescription: result.description,
                     thumbImageURL: result.urls.thumb,
                     largeImageURL: result.urls.full,
                     isLiked: result.likedByUser)
    }
    
    private func makeImageListRequest(page: Int) -> URLRequest? {
        let baseURL = Constants.defaultBaseURL
        
        guard let url = URL(
            string: "/photos"
            + "?page=\(page)",
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let token = storage.token else {
            print("Не удалось загрузить токен")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        let baseURL = Constants.defaultBaseURL
        
        guard let url = URL(string: "/photos/\(photoId)/like", relativeTo: baseURL) 
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let token = storage.token else {
            print("Не удалось загрузить токен")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
