//
//  RateFluctuationDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol RateFluctuationDataProviderDeletegate: DataProviderManagerDelegate {
    func success(model: RatesFluctuationObject)
}

class RatesFluctuationDataProvider: DataProviderManager<RateFluctuationDataProviderDeletegate, RatesFluctuationObject> {
    
    private let ratesStore: RatesStore
    
    init(ratesStore: RatesStore = RatesStore()) {
        self.ratesStore = ratesStore
    }
    
    func fetchFluctuation(by base: String, from symbols: [String], starDate: String, endDate: String) {
        Task.init {
            do {
                let model = try await ratesStore.fetchFluctuation(by: base, form: symbols, startDate: starDate, endDate: endDate)
                delegate?.success(model: model)
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
