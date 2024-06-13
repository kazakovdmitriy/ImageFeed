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
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        let buttonImage = UIImage(named: "NoActiveLike")
        
        button.setImage(buttonImage, for: .normal)
        button.backgroundColor = .clear
        button.accessibilityIdentifier = "NoActiveLike"
        
        return button
        
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.ypWhite
        label.backgroundColor = .clear
        
        return label
    }()
    
    lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    private lazy var dateBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    // MARK: - Private Properties
    private lazy var animationView = UIView()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        // selectedBackgroundView?.backgroundColor = .clear
        // multipleSelectionBackgroundView?.backgroundColor = .clear
        selectionStyle = .none
        
        clipsToBounds = true
        
        setupViews()
        contraintViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateBackgroundView.setGradientBackground(startColor: .clear, endColor: UIColor.ypBlack, opacity: 0.2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupDateBackgroundOutlet(cornerRadius: 16)
    }
    
    // MARK: - Public Methods
    func setIsLiked(isLiked: Bool) {
        let likeImage: UIImage? = isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NoActiveLike")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = isLiked ? "ActiveLike" : "NoActiveLike"
    }
    
    // MARK: - Private Methods
    private func setupDateBackgroundOutlet(cornerRadius: Double) {
        
        dateBackgroundView.layer.mask?.removeFromSuperlayer()
        
        let maskPath = UIBezierPath(roundedRect: dateBackgroundView.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        dateBackgroundView.layer.mask = maskLayer
    }
    
    @objc private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    private func setupViews() {
        [cellImage, likeButton, dateLabel].forEach {
            $0.backgroundColor = .clear
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
    }
    
    private func contraintViews() {
        NSLayoutConstraint.activate([
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8)
        ])
    }
}
