//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий on 17.05.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private init() {}
    
    private let bearerTokenKey = "OAuth2BearerToken"
    
    var token: String? {
        get {
            guard let token = KeychainWrapper.standard.string(forKey: bearerTokenKey) else {
                print("[OAuth2TokenStorage]: не удалось получить токен")
                return nil
            }
            return token
        }
        
        set {
            guard let token = newValue else { return }
            
            let isSuccess = KeychainWrapper.standard.set(token, forKey: bearerTokenKey)
            guard isSuccess else {
                print("[OAuth2TokenStorage]: не удалось сохранить токен")
                return
            }
        }
    }
}
