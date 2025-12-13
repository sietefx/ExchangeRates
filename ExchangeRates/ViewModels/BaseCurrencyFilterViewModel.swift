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
    class ViewModel: ObservableObject, CurrencySymbolsDataProviderDelegate, DataProviderManagerDelegate {
        
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
        
        // MARK: - DataProviderManagerDelegate
        // Implemente os métodos EXATAMENTE como o protocolo exige:
        func success(model: Any) {
            // Desembrulhe o modelo baseado no tipo
            if let currencySymbols = model as? [CurrencySymbolModel] {
                self.currencySymbols = currencySymbols.sorted { $0.symbol < $1.symbol }
            }
        }
        
        func errorData(_ provider: DataProviderManagerDelegate?, error: Error) {
            print("Error from provider: \(error.localizedDescription)")
            // Aqui você pode adicionar lógica para mostrar erros na UI se quiser
        }
        
        // Se quiser manter seus métodos personalizados também, pode:
        func didStartRequest() {
            // Lógica opcional de loading
        }

        func didFinishRequest() {
            // Lógica opcional de fim de loading
        }
    }
}
