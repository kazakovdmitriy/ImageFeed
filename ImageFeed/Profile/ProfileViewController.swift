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

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol { get set }
    
    func fillProfile(profile: Profile)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    // MARK: - Public Properties
    var presenter: ProfileViewPresenterProtocol
    
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var nameLabel: UILabel = presenter.makeLabel(text: "", fontSize: 23, color: UIColor.ypWhite, fontStyle: .bold)
    private lazy var loginLabel: UILabel = presenter.makeLabel(text: "", fontSize: 13, color: UIColor.ypGray, fontStyle: .regular)
    private lazy var bioLabel: UILabel = presenter.makeLabel(text: "", fontSize: 13, color: UIColor.ypWhite, fontStyle: .regular)
    
    private let avatarImage: UIImageView = {
        let image = UIImage(named: "Userpick")
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Logout")
        button.setImage(image, for: .normal)
        button.accessibilityIdentifier = "logout button"
        button.tintColor = UIColor(named: "YP Red") ?? UIColor.red
        
        return button
    }()
    
    // MARK: - Initializer
    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObserver()
        setupViews()
        constraintViews()
        
        updateAvatar()
        presenter.updateProfileInfo()
    }
    
    // MARK: - Public Methods
    func fillProfile(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = "@\(profile.username)"
        bioLabel.text = profile.bio
    }
    
    // MARK: - Private Methods
    private func updateAvatar() {
        
        guard let url = presenter.getAvatarImageURL() else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 450)
        
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: url,
                                placeholder: UIImage(named: "placeholder"),
                                options: [.processor(processor)])
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main) { [weak self] _ in
                guard let self = self else { return}
                self.updateAvatar()
            }
    }
        
    private func setupViews() {
        
        view.backgroundColor = UIColor.ypBlack
        
        [avatarImage,
         nameLabel,
         loginLabel,
         bioLabel,
         exitButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        bioLabel.lineBreakMode = .byWordWrapping
        bioLabel.numberOfLines = 0
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
            
            bioLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
        ])
    }
    
    private func showLogoutAlert() {
        let alertController = presenter.makeLogoutAlert()
        
        present(alertController, animated: true)
    }
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
}
