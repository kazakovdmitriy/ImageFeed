//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Дмитрий on 08.05.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseURL = URL(string: "https://unsplash.com")
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        )!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completition: @escaping (Result<String,Error>) -> Void){
        let urlRequest = makeOAuthTokenRequest(code: code)
        
        guard let urlRequest = urlRequest else { return }
        
        let task = URLSession.shared.data(for: urlRequest){ result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completition(.success(response.accessToken))
                    
                } catch {
                    completition(.failure(error))
                    
                }
            case .failure(let error):
                completition(.failure(error))
            }
            
        }
        task.resume()
    }
}
