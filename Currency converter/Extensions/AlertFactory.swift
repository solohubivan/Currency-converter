//
//  AlertFactory.swift
//  Currency converter
//
//  Created by Ivan Solohub on 27.12.2023.
//

import UIKit

class AlertFactory {
    static func createAlert(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}
