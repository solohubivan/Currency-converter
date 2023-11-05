//
//  String.swift
//  Currency converter
//
//  Created by Ivan Solohub on 05.11.2023.
//

import UIKit

extension String {
    
    func formattedText(mask: String) -> String {
        let cleanText = self.replacingOccurrences(of: ".", with: "")
        
        var result = ""
        var index = cleanText.startIndex
        
        for ch in mask where index < cleanText.endIndex {
            if "dmy".contains(ch) {
                let character = cleanText[index]
                if character.isNumber {
                    result.append(character)
                    index = cleanText.index(after: index)
                } else {
                    break
                }
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
