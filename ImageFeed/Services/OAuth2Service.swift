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
    
    func fetchOAuthToken(code: String, completition: @escaping (Result<String,Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completition(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completition(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let answer: OAuthTokenResponseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                            
                            self.storage.token = answer.accessToken
                            
                            completition(.success(answer.accessToken))
                        } catch {
                            print(error.localizedDescription)
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
                self.lastCode = nil
            }
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
