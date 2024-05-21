//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий on 08.05.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let storage = OAuth2TokenStorage.shared
    
    private init() {}
    
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
            print("Failed to create URL")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completition: @escaping (Result<String,Error>) -> Void){
        let urlRequest = makeOAuthTokenRequest(code: code)
        
        guard let urlRequest = urlRequest else {
            assertionFailure("Failed to send request")
            return
        }
        
        let task = URLSession.shared.data(for: urlRequest) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.token = response.accessToken
                    completition(.success(response.accessToken))
                } catch {
                    print(error)
                    completition(.failure(error))
                }
            case .failure(let error):
                print(error)
                completition(.failure(error))
            }
            
        }
        
        task.resume()
    }
}
