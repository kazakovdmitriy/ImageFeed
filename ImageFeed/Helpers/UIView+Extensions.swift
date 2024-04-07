//
//  UILabel+Extensions.swift
//  ImageFeed
//
//  Created by Дмитрий on 06.04.2024.
//

import UIKit

extension UIView {
    func setGradientBackground(startColor: UIColor, endColor: UIColor, opacity: Float) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        gradientLayer.opacity = opacity
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
