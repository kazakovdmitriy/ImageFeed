//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий on 26.05.2024.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
    case noData
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    private let storage = OAuth2TokenStorage.shared
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if avatarURL != nil { return }
        task?.cancel()
        
        guard
            let request = makeProfileImageRequest(username: username)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let answer):
                self.avatarURL = answer.profileImage.small
                
                guard let avatarURL = avatarURL else { return }
                
                completion(.success(avatarURL))
                
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL": avatarURL])
            case .failure(let error):
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        let baseURL = Constants.defaultBaseURL
        
        guard let url = URL(
            string: "/users/\(username)",
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
}
