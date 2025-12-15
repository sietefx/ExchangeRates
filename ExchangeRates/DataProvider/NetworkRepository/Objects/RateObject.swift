//
//  RateObject.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 13/12/25.
//

import Foundation

struct RateObject<Rates: Codable>: Codable {
    var base: String?
    var success: Bool = false
    var rates: Rates?
}

typealias RatesFluctuationObject = [String: FluctuationObject]

struct FluctuationObject: Identifiable, Codable {
    
    let id = UUID()
    let change: Double
    let changePct: Double
    let endRate: Double
    
    // por causa de um n no meio de CodingKeys, tava dando erro no meu projeto, provavelmente causando todo o crash
    enum CodingKeys: String, CodingKey {
        case change
        case changePct = "change_pct"
        case endRate = "end_rate"
    }
}

typealias RatesHistoricalObject = [String: [String: Double]]
