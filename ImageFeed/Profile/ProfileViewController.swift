//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 12.04.2024.
//

import UIKit
import Kingfisher

enum FontStyle {
    case bold
    case regular
}

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private let logoutService = ProfileLogoutService.shared
    
    private lazy var nameLabel: UILabel = makeLabel(text: "", fontSize: 23, colorName: "YP White", fontStyle: .bold)
    private lazy var loginLabel: UILabel = makeLabel(text: "", fontSize: 13, colorName: "YP Gray", fontStyle: .regular)
    private lazy var statusLabel: UILabel = makeLabel(text: "", fontSize: 13, colorName: "YP White", fontStyle: .regular)
    
    private let avatarImage: UIImageView = {
        let image = UIImage(named: "Userpick")
        let imageView = UIImageView(image: image)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let exitButton: UIButton = {
        let image = UIImage(named: "Logout")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "YP Red") ?? UIColor.red
    
        return button
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main) { [weak self] _ in
                guard let self = self else { return}
                self.updateAvatar()
            }
        
        updateAvatar()
        updateProfileInfo()
        
        setupViews()
        constraintViews()
    }

    // MARK: - Private Methods
    private func makeLabel(text: String, fontSize: CGFloat, colorName: String, fontStyle: FontStyle) -> UILabel {
        let label = UILabel()
        label.text = text
        
        switch fontStyle {
        case .bold:
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
        case .regular:
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        label.textColor = UIColor(named: colorName) ?? UIColor.white
        
        return label
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
                
        let processor = RoundCornerImageProcessor(cornerRadius: 450)
        
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: url,
                                placeholder: UIImage(named: "placeholder"),
                                options: [.processor(processor)])
    }
    
    private func updateProfileInfo() {
        guard let profile = profileService.profile else { return }
        
        fillProfile(profile: profile)
    }
    
    private func setupViews() {
        
        [avatarImage,
         nameLabel,
         loginLabel,
         statusLabel,
         exitButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        exitButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
    }
    
    private func constraintViews() {
        NSLayoutConstraint.activate([
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
        ])
    }
    
    private func fillProfile(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.username
        statusLabel.text = profile.bio
    }
    
    private func switchToSplashScreen() {
        let splashViewController = SplashViewController()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = splashViewController
    }
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
}

// MARK: - UIAlertController
extension ProfileViewController {
    private func showLogoutAlert() {
        
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
        
        present(alertController, animated: true)
    }
}
