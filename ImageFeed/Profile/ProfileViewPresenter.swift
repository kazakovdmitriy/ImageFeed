//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий on 11.06.2024.
//

import UIKit
import Kingfisher

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    
    func makeLogoutAlert() -> UIAlertController
    func makeLabel(text: String, fontSize: CGFloat, color: UIColor, fontStyle: FontStyle) -> UILabel
    func getAvatarImageURL() -> URL?
    func updateProfileInfo()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Public Properties
    var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    private let logoutService: ProfileLogoutServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    // MARK: - Initializer
    init(view: ProfileViewControllerProtocol? = nil, 
         logoutService: ProfileLogoutServiceProtocol,
         profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol) {
        
        self.view = view
        self.logoutService = logoutService
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    // MARK: - Public Methods
    func updateProfileInfo() {
        guard let profile = profileService.profile else { return }
        
        view?.fillProfile(profile: profile)
    }
    
    
    func getAvatarImageURL() -> URL? {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return nil
        }
        
        return url
    }
    
    func makeLabel(text: String,
                   fontSize: CGFloat,
                   color: UIColor,
                   fontStyle: FontStyle) -> UILabel {
        let label = UILabel()
        label.text = text
        
        switch fontStyle {
        case .bold:
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
        case .regular:
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        label.textColor = color
        
        return label
    }
    
    func makeLogoutAlert() -> UIAlertController {
        let alertController = UIAlertController(title: "Пока, пока!",
                                                message: "Уверены что хотите выйти?",
                                                preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.logoutService.logout()
            self.switchToSplashScreen()
        }
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        return alertController
    }
    
    // MARK: - Private Methods
    private func switchToSplashScreen() {
        let splashViewController = SplashViewController()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = splashViewController
    }
    
}
