//
//  RatesHistoricalDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol RatesHistoricalDataProviderDeletegate: DataProviderManagerDelegate {
    func success(model: RatesHistoricalObject)
}

class RatesHistoricalDataProvider: DataProviderManager<RatesHistoricalDataProviderDeletegate, RatesHistoricalObject> {
    
    private let ratesStore: RatesStore
    
    init(ratesStore: RatesStore = RatesStore()) {
        self.ratesStore = ratesStore
    }
    
    func fetchTimeseries(by base: String, from symbols: [String], startDate: String, endDate: String) {
        Task.init {
            do {
                let model = try await ratesStore.fetchTimeseries(by: base, from: symbols, startDate: startDate, endDate: endDate)
                delegate?.success(model: model)
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
