//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дмитрий on 05.06.2024.
//

import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListSerivce = ImagesListService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private init() { }
    
    func logout() {
        
        storage.cleanToken()
        
        cleanCookies()
        
        profileService.clean()
        profileImageService.clean()
        imagesListSerivce.clean()
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
