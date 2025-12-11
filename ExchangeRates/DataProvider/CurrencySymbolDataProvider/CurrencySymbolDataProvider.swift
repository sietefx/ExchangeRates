//
//  CurrencySymbolDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol CurrencySymbolDataProviderDelegate: DataProviderManagerDelegate {
    func success(model: [CurrencySymbolModel])
}

class CurrencySymbolDataProvider: DataProviderManager<CurrencySymbolDataProviderDelegate, [CurrencySymbolModel]> {
    
    private let currencyStore: CurrencyStore
    
    init(currencyStore: CurrencyStore = CurrencyStore()) {
        self.currencyStore = currencyStore
    }
    
    func fetchSymbols(by base: String, from symbols: [String], startDate: String, endDate: String) {
        Task.init {
            do {
                let object = try await currencyStore.fetchSymbols()
                delegate?.success(model: object.map({ (symbol, fullName) -> CurrencySymbolModel in
                    return CurrencySymbolModel(symbol: symbol, fullName: fullName)
                }))
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
