//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 17.05.2024.
//

import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    private let authScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    private let splashLogo: UIImageView = {
        let image = UIImage(named: "auth_screen_logo")
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        constraintViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            switchToAuthController()
        }
    }
    
    private func setupViews() {
        
        view.backgroundColor = UIColor.ypBlack
        
        view.addSubview(splashLogo)
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func constraintViews() {
        NSLayoutConstraint.activate([
            splashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashLogo.widthAnchor.constraint(equalToConstant: 75),
            splashLogo.heightAnchor.constraint(equalToConstant: 77),
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func switchToAuthController() {
        guard let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                
                let username = profile.username
                
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                
                self.switchToTabBarController()
            case .failure(let error):
                print("[SplashViewController]: \(error.localizedDescription)")
                showErrorAlert()
            }
        }
    }
}

extension SplashViewController {
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так",
                                                message: "Не удалось войти в систему",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
