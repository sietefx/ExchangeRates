//
//  MultiCurrenciesFilterViewModel.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 11/12/25.
//

import Foundation
import SwiftUI
import Combine

extension MultiCurrenciesFilterView {
    @MainActor class ViewModel: ObservableObject, CurrencySymbolsDataProviderDelegate {
        @Published var currencySymbols = [CurrencySymbolModel]()
        
        private let dataProvider: CurrencySymbolsDataProvider
        
        // Initialize everything on MainActor - this is the cleanest approach
        init(dataProvider: CurrencySymbolsDataProvider) {
            self.dataProvider = dataProvider
            self.dataProvider.delegate = self
        }
        
        // Convenience initializer that doesn't take parameters
        convenience init() {
            self.init(dataProvider: CurrencySymbolsDataProvider())
        }
        
        func doFetchCurrencySymbols(
            by query: String = "",
            from sources: [String] = [],
            startDate: String? = nil,
            endDate: String? = nil) {
            dataProvider.fetchSymbols(
                by: query,
                from: sources,
                startDate: startDate ?? "",
                endDate: endDate ?? "")
        }
        
        // This is on MainActor automatically because the class is @MainActor
        func success(model: [CurrencySymbolModel]) {
            self.currencySymbols = model.sorted { $0.symbol < $1.symbol }
        }
    }
}
