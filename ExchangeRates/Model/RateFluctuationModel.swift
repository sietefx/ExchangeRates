//
//  RateFluctuationModel.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 11/12/25.
//

import Foundation

struct RateFluctuationModel: Identifiable {
    let id: UUID
    var symbol: String
    var change: Double
    var changePct: Double
    var endRate: Double

    init(id: UUID = UUID(), symbol: String, change: Double, changePct: Double, endRate: Double) {
        self.id = id
        self.symbol = symbol
        self.change = change
        self.changePct = changePct
        self.endRate = endRate
    }
}
