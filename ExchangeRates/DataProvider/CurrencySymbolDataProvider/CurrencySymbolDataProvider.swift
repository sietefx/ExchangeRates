//
//  CurrencySymbolDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol CurrencySymbolDataProviderDeletegate: DataProviderManagerDelegate {
    func success(model: CurrencySymbolObject)
}

class CurrencySymbolDataProvider: DataProviderManager<CurrencySymbolDataProviderDeletegate, CurrencySymbolObject> {
    
    private let currencyStore: CurrencyStore
    
    init(currencyStore: CurrencyStore = CurrencyStore()) {
        self.currencyStore = currencyStore
    }
    
    func fetchSymbols(by base: String, from symbols: [String], starDate: String, endDate: String) {
        Task.init {
            do {
                let model = try await currencyStore.fetchSymbols()
                delegate?.success(model: model)
            } catch {
                delegate?.errorData(delegate, error: error)
            }
        }
    }
}
