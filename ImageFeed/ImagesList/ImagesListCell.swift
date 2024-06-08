//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий on 05.04.2024.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var cellImageOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
    @IBOutlet private weak var dateBackgroundOutlet: UIView!

    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Private Properties
    private lazy var animationView = UIView()

    // MARK: - Overrides Methods
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
    
    // MARK: - IB Actions
    @IBAction private func didTapLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    func setIsLiked(isLiked: Bool) {
        let likeImage: UIImage? = isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NoActiveLike")
        likeButtonOutlet.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Private Methods
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
