//
//  CurrencyStore.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol CurrencyStoreProtocol: GenericStoreProtocol {
    func fetchSymbols(completion: @escaping completion<CurrencySymbolObject?>) // Corrigido
}

class CurrencyStore: GenericStoreRequest, CurrencyStoreProtocol {
    
    func fetchSymbols(completion: @escaping completion<CurrencySymbolObject?>) { // Corrigido
        guard let urlRequest = CurrencyRouter.symbols.asURLRequest() else {
            return completion(nil, error)
        }
        request(urlRequest: urlRequest, completion: completion)
    }
}
