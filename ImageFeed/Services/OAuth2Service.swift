//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий on 08.05.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String,Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let answer):
                self.storage.token = answer.accessToken
                completion(.success(answer.accessToken))
            case .failure(let error):
                print("[OAuth2Service]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
        }
                        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
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
