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

    // MARK: - Public Properties
    static let shared = ProfileLogoutService()

    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListSerivce = ImagesListService.shared
    private let storage = OAuth2TokenStorage.shared

    // MARK: - Initializers
    private init() {}

    // MARK: - Public Methods
    func logout() {
        
        storage.cleanToken()
        
        cleanCookies()
        
        profileService.clean()
        profileImageService.clean()
        imagesListSerivce.clean()
    }
    
    // MARK: - Private Methods
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
