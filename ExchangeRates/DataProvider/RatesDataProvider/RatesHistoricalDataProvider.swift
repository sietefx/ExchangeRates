//
//  RatesHistoricalDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol RatesHistoricalDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [RatesHistoricalModel])
}

class RatesHistoricalDataProvider: DataProviderManager<RatesHistoricalDataProviderDelegate, RatesHistoricalModel> {
    
    private let ratesStore: RatesStore
    
    init(ratesStore: RatesStore = RatesStore()) {
        self.ratesStore = ratesStore
    }
    
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String) {
        Task {
            do {
                let object = try await ratesStore.fetchTimeseries(by: base, from: symbol, startDate: startDate, endDate: endDate)
                delegate?.success(model: object.flatMap({ (period, rates) -> [RatesHistoricalModel] in
                    return rates.map { RatesHistoricalModel(symbol: $0, period: period.toDate(), endRate: $1) }
                }))
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
