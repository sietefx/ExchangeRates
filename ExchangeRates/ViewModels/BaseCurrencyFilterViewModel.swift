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
    class ViewModel: ObservableObject, CurrencySymbolsDataProviderDelegate {
        
        @Published var currencySymbols = [CurrencySymbolModel]()
        private let dataProvider: CurrencySymbolsDataProvider
        
        // Factory method - Mantém a lógica async se necessário
        static func create() -> ViewModel {
            let dataProvider = CurrencySymbolsDataProvider()
            let viewModel = ViewModel(dataProvider: dataProvider)
            dataProvider.delegate = viewModel
            return viewModel
        }
        
        // Mude de private para fileprivate ou internal
        fileprivate init(dataProvider: CurrencySymbolsDataProvider) {
            self.dataProvider = dataProvider
        }
        
        func doFetchCurrencySymbols() {
            dataProvider.fetchSymbols(
                by: "",
                from: [],
                startDate: "",
                endDate: ""
            )
        }
        
        func success(model: [CurrencySymbolModel]) {
            self.currencySymbols = model.sorted { $0.symbol < $1.symbol }
        }
    }
}
