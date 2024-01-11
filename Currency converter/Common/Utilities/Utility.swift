//
//  Utility.swift
//  Currency converter
//
//  Created by Ivan Solohub on 27.12.2023.
//

import UIKit

extension UIDevice {
    static var isIpad: Bool {
        return current.userInterfaceIdiom == .pad
    }
}
