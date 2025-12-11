//
//  BaseCurrencyFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 11/12/25.
//

import Foundation
import SwiftUI
import Combine

extension BaseCurrencyFilterView {
    @MainActor
    class ViewModel: ObservableObject, CurrencySymbolDataProviderDelegate {
        @Published var currencySymbols = [CurrencySymbolModel]()
        
        private let dataProvider: CurrencySymbolDataProvider
        
        // Construtor que recebe o dataProvider
        init(dataProvider: CurrencySymbolDataProvider) {
            self.dataProvider = dataProvider
            self.dataProvider.delegate = self
        }
        
        // Construtor conveniência que cria o dataProvider
        convenience init() {
            // Como estamos dentro de um @MainActor class, podemos chamar o init
            let dataProvider = CurrencySymbolDataProvider()
            self.init(dataProvider: dataProvider)
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
        
        func success(model: [CurrencySymbolModel]) {
            self.currencySymbols = model.sorted { $0.symbol < $1.symbol }
        }
    }
}
