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
                reversedIntegerPart.index(reversedIntegerPart.startIndex, offsetBy: $0)..<reversedIntegerPart.index(reversedIntegerPart.startIndex, offsetBy: min($0 + 3, reversedIntegerPart.count))
            }.map {
                reversedIntegerPart[$0]
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

    func isValidForTextField() -> Bool {

        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.")
        if self.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
            return false
        }

        let dotCount = self.filter { $0 == "." }.count
        if dotCount > 1 {
            return false
        }

        if self.count > 13 {
            return false
        }

        return true
    }
}
