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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if profile != nil { return }
        task?.cancel()
        
        guard
            let request = makeProfileRequest(token: token) 
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let answer):
                let profile = Profile(username: answer.username,
                                      name: "\(answer.firstName) \(answer.lastName)",
                                      loginName: "@\(answer.username)",
                                      bio: answer.bio ?? "")
                
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self.task = nil
        }
                
        self.task = task
        task.resume()
    }
    
    func clean() {
        profile = nil
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        let baseURL = Constants.defaultBaseURL
        
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
