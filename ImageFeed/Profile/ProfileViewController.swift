//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 12.04.2024.
//

import UIKit

enum FontStyle {
    case bold
    case regular
}

final class ProfileViewController: UIViewController {
    
    private let avatarImage: UIImageView = {
        let image = UIImage(named: "Userpick")
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = makeLabel(text: "Екатерина Новикова", fontSize: 23, colorName: "YP White", fontStyle: .bold)
    private lazy var loginLabel: UILabel = makeLabel(text: "@ekaterina_nov", fontSize: 13, colorName: "YP Gray", fontStyle: .regular)
    private lazy var statusLabel: UILabel = makeLabel(text: "Hello, world!", fontSize: 13, colorName: "YP White", fontStyle: .regular)
    
    private let exitButton: UIButton = {
        let image = UIImage(named: "Logout")
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "YP Red") ?? UIColor.red
    
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        constraintViews()
    }
    
    private func makeLabel(text: String, fontSize: CGFloat, colorName: String, fontStyle: FontStyle) -> UILabel {
        let label = UILabel()
        label.text = text
        
        switch fontStyle {
        case .bold:
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
        case .regular:
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        if colorName == "YP White" {
            label.textColor = UIColor(named: colorName) ?? UIColor.white
        } else {
            label.textColor = UIColor(named: colorName) ?? UIColor.gray
        }
        
        return label
    }
    
    private func setupViews() {
        
        view.addSubview(avatarImage)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loginLabel)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc private func didTapLogoutButton() {
        print("Пользователь хочет выйти")
    }
}
