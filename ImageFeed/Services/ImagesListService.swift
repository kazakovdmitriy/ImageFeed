//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий on 29.05.2024.
//

import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
}

final class ImagesListService {
    
    static let shared = ImagesListCell()
    private init() {}
    
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        fetchPhotos(page: nextPage) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let photos):
                self.photos += photos
            case .failure(let error):
                print("[ImagesListService]: \(error.localizedDescription)")
            }
            
        }
    }
    
    private func fetchPhotos(page: Int, _ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // if avatarURL != nil { return }
        task?.cancel()
        
        guard
            let request = makeImageListRequest(page: page)
        else {
            completion(.failure(ImagesListServiceError.invalidRequest))
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
                     isLiked: false)
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
