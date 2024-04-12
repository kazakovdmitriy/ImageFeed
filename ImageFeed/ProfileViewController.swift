//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 12.04.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var avatarImageOutlet: NSLayoutConstraint!
    @IBOutlet private weak var nameLabelOutlet: UILabel!
    @IBOutlet private weak var loginLabelOutlet: UILabel!
    @IBOutlet private weak var statusLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction private func logoutAction(_ sender: Any) {
        print("Пользователь хочет выйти")
    }
}
