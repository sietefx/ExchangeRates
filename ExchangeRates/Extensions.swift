//
//  Extensions.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import Foundation
import SwiftUI

extension Double {
    
    var color: Color {
        if self.sign == .minus {
            return .red
        } else {
            return .green
        }
    }
    
    func formatter(decimalPlaces: Int, with changeSymbol: Bool = false) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .halfUp
        numberFormatter.minimumFractionDigits = (decimalPlaces > 2) ? decimalPlaces : 2
        numberFormatter.maximumFractionDigits = (decimalPlaces > 2) ? decimalPlaces : 2
        numberFormatter.locale = Locale(identifier: "pt_BR")
        
        guard let value = numberFormatter.string(from: NSNumber(value: self)) else { return String(self) }
        
        if changeSymbol {
            if self.sign == .minus {
                return "\(value)"
            } else {
                return "+\(value)"
            }
        }
        return value.replacingOccurrences(of: "-", with: "")
    }
    func toPercentage(with changeSymbol: Bool = false) -> String {
        let value = formatter(decimalPlaces: 2)
        
        if changeSymbol {
            if self.sign == .minus {
                return "\u{2193} \(value)%"
            } else {
                return "\u{2191} \(value)%"
            }
        }
        return "\(value)%"
    }
}
 
