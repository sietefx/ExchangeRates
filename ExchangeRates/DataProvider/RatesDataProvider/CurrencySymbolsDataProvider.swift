//
//  CurrencySymbolsDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 13/12/25.
//

import Foundation
import Combine

enum CurrencySymbolsError: Error {
    case missingSymbols
    case providerDeallocated
}

protocol CurrencySymbolsDataProviderProtocol {
    func fetchSymbols() -> AnyPublisher<[CurrencySymbolModel], Error>
}

class CurrencySymbolsDataProvider: CurrencySymbolsDataProviderProtocol {
    
    private let currencyStore: CurrencyStore
    
    init(currencyStore: CurrencyStore = CurrencyStore()) {
        self.currencyStore = currencyStore
    }
    
    func fetchSymbols() -> AnyPublisher<[CurrencySymbolModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(CurrencySymbolsError.providerDeallocated))
            }
            self.currencyStore.fetchSymbols { result, error in
                DispatchQueue.main.async {
                    if let error {
                        return promise(.failure(error))
                    }

                    guard let symbols = result?.symbols else {
                        return promise(.failure(error ?? CurrencySymbolsError.missingSymbols))
                    }

                    let currenciesSymbol = symbols.map({ (key, value) -> CurrencySymbolModel in
                        return CurrencySymbolModel(symbol: key, fullName: value)
                    })
                    return promise(.success(currenciesSymbol))
                }
            }
        }.eraseToAnyPublisher()
    }
}

