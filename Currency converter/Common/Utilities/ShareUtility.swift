//
//  ShareUtility.swift
//  Currency converter
//
//  Created by Ivan Solohub on 27.12.2023.
//

import UIKit

class ShareUtility {
    static func createShareViewController(textToShare: String, sourceView: UIView) -> UIActivityViewController {
        let shareViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

        if let popoverController = shareViewController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }

        return shareViewController
    }
}
