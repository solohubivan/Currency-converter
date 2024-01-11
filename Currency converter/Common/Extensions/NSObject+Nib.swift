//
//  NSObject+ClassName.swift
//  Currency converter
//
//  Created by Ivan Solohub on 22.12.2023.
//

// import Foundation
import UIKit

extension NSObject {

    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
