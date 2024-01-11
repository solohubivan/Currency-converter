//
//  String+Ext.swift
//  Currency converter
//
//  Created by Ivan Solohub on 17.12.2023.
//

import UIKit

extension String {
    func formattedWithSeparator() -> String {
        let parts = self.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)

        let integerPart = parts[0].replacingOccurrences(of: " ", with: "")
        let reversedIntegerPart = String(integerPart.reversed())

        let spacedIntegerPart = stride(from: 0, to: reversedIntegerPart.count, by: 3).map {
            let startIndex = reversedIntegerPart.index(reversedIntegerPart.startIndex, offsetBy: $0)
            let offset = min($0 + 3, reversedIntegerPart.count)
            let endIndex = reversedIntegerPart.index(reversedIntegerPart.startIndex, offsetBy: offset)
            return String(reversedIntegerPart[startIndex..<endIndex])

        }.joined(separator: " ")

        let formattedIntegerPart = String(spacedIntegerPart.reversed())

            if parts.count > 1 {
                let decimalPart = parts[1]
                return "\(formattedIntegerPart).\(decimalPart)"
            } else {
                return formattedIntegerPart
            }
        }

    func removingSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func replacingCommaWithDot() -> String {
        return self.replacingOccurrences(of: ",", with: ".")
    }

    func replaceSingleDotIfNeeded() -> String {
        if self == "." {
            return "0."
        }
        return self
    }
}
