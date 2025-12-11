//
//  RateFluctuationDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol RateFluctuationDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [RateFluctuationModel])
}

class RatesFluctuationDataProvider: DataProviderManager<RateFluctuationDataProviderDelegate, [RateFluctuationModel]> {
    
    private let ratesStore: RatesStore
    
    init(ratesStore: RatesStore = RatesStore()) {
        self.ratesStore = ratesStore
    }
    
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String) {
        Task {
            do {
                let object = try await ratesStore.fetchFluctuation(by: base, from: symbols, startDate: startDate, endDate: endDate)
                await MainActor.run {
                    delegate?.success(model: object.map({ (symbol, fluctuation) -> RateFluctuationModel in
                        return RateFluctuationModel(symbol: symbol, change: fluctuation.change, changePct: fluctuation.changePct, endRate: fluctuation.endRate)
                    }))}
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
