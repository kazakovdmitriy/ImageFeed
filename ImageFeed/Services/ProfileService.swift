//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дмитрий on 23.05.2024.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completition: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard 
            let request = makeProfileRequest(token: token) 
        else {
            completition(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let answer: ProfileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                            let profile = Profile(username: answer.username,
                                                  name: "\(answer.firstName) \(answer.lastName)",
                                                  loginName: "@\(answer.username)",
                                                  bio: answer.bio ?? "")
                            
                            self.profile = profile
                            
                            completition(.success(profile))
                        } catch {
                            print(String(describing: error))
                        }
                    } else {
                        assertionFailure("Failed to load page. Code: \(statusCode)")
                        completition(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    assertionFailure("Failed to load page. With error: \(error)")
                    completition(.failure(NetworkError.urlRequestError(error)))
                } else {
                    assertionFailure("Failed to load page")
                    completition(.failure(NetworkError.urlSessionError))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        let baseURL = URL(string: "https://api.unsplash.com")
        
        guard let url = URL(
            string: "/me",
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
