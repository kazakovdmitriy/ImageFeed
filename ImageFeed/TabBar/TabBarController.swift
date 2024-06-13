//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Дмитрий on 28.05.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imagesListPresenter = ImagesListPresenter(imageListService: ImagesListService.shared)
        let imagesListViewController = ImagesListViewController(presenter: imagesListPresenter)
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        let profileImageService = ProfileImageService.shared
        let profileService = ProfileService.shared
        let logoutService = ProfileLogoutService.shared
        
        let profileViewPresenter = ProfileViewPresenter(logoutService: logoutService, profileService: profileService, profileImageService: profileImageService)
        let profileViewController = ProfileViewController(presenter: profileViewPresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
