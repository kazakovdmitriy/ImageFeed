//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий on 05.04.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var dateBackgroundOutlet: UIView!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var cellImageOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
    
    
    static let reuseIdentifier = "ImagesListCell"
}
