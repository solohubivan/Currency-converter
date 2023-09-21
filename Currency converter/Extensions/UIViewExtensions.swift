//
//  UIViewExtensions.swift
//  Currency converter
//
//  Created by Ivan Solohub on 19.09.2023.
//

import UIKit

extension UIView {
    
    func applyShadow(color: UIColor = UIColor.black, opacity: Float = 1, offset: CGSize = CGSize(width: 2, height: 4), radius: CGFloat = 4, cornerRadius: CGFloat = 0) {
        
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
}
