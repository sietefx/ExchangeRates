//
//  RateHistoricalModel.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 11/12/25.
//

import Foundation

struct RatesHistoricalModel: Identifiable {
    let id = UUID()
    var symbol: String
    var period: Date
    var endRate: Double
}
