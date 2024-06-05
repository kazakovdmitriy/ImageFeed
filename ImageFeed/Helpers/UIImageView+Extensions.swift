//
//  UIImageView+Extensions.swift
//  ImageFeed
//
//  Created by Дмитрий on 04.06.2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImageWithPlaceholder(url: URL?,
                                 placeholder: UIImage?,
                                 placeholderContentMode: UIView.ContentMode,
                                 contentMode: UIView.ContentMode,
                                 completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil)
    {
        self.contentMode = placeholderContentMode
        
        self.kf.setImage(with: url, placeholder: placeholder, options: nil) { result in
            self.contentMode = contentMode
            
            completionHandler?(result)
        }
    }
}
