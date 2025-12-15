//
//  CurrencySymbolObject.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

// Modelo para a resposta da API APILayer
struct CurrencySymbolObject: Codable {
    var base: String?
    var success: Bool = false
    var symbols: SymbolObject?
}
    
typealias SymbolObject = [String: String]
