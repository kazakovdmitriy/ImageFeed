//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Дмитрий on 26.05.2024.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
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
        
        guard
            let request = makeProfileImageRequest(username: username)
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let answer: UserResult = try JSONDecoder().decode(UserResult.self, from: data)
                            let avatarURL = answer.profileImage.small
                            
                            self.avatarURL = avatarURL
                            
                            completion(.success(avatarURL))
                            
                            NotificationCenter.default
                                .post(name: ProfileImageService.didChangeNotification,
                                      object: self,
                                      userInfo: ["URL": avatarURL])
                        } catch {
                            print(String(describing: error))
                        }
                    } else {
                        assertionFailure("Failed to load page. Code: \(statusCode)")
                        completion(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    assertionFailure("Failed to load page. With error: \(error)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                } else {
                    assertionFailure("Failed to load page")
                    completion(.failure(NetworkError.urlSessionError))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
        
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
