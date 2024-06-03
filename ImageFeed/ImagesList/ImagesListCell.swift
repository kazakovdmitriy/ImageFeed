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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateBackgroundOutlet.setGradientBackground(startColor: .clear, endColor: UIColor.ypBlack, opacity: 0.2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageOutlet.kf.cancelDownloadTask()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupDateBackgroundOutlet(cornerRadius: 16)
    }
    
    private func setupDateBackgroundOutlet(cornerRadius: Double) {
        
        dateBackgroundOutlet.layer.mask?.removeFromSuperlayer()
        
        let maskPath = UIBezierPath(roundedRect: dateBackgroundOutlet.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        dateBackgroundOutlet.layer.mask = maskLayer
    }
}
