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
    @MainActor class ViewModel: ObservableObject {
        
        enum ViewState {
            case start
            case loading
            case success
            case failure
        }
        
        @Published var currencySymbols = [CurrencySymbolModel]()
        @Published var searchResults = [CurrencySymbolModel]()
        @Published var currentState: ViewState = .start
        
        private let dataProvider: CurrencySymbolsDataProvider?
        private var cancelables = Set<AnyCancellable>()
        
        init(dataProvider: CurrencySymbolsDataProvider? = nil) {
            self.dataProvider = dataProvider ?? CurrencySymbolsDataProvider()
        }
        
        func doFetchCurrencySymbols() {
            currentState = .loading
            dataProvider?.fetchSymbols()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.currentState = .success
                    case .failure(_):
                        self.currentState = .failure
                    }
                }, receiveValue: { currencySymbols in
                    withAnimation {
                        self.currencySymbols = currencySymbols.sorted { $0.symbol < $1.symbol }
                        self.searchResults = self.currencySymbols
                    }
                }).store(in: &cancelables)
        }
    }
}
