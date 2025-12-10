//
//  DataProviderManager.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol DataProviderManagerDelegate {
    func success(model: Any)
    func errorData(_ provider: DataProviderManagerDelegate?, error: Error)
}

extension DataProviderManagerDelegate {
    func success(model: Any) {
        preconditionFailure("This method must be overridden")
    }
    func errorData(_ provider: DataProviderManagerDelegate?, error: Error) {
        print(error.localizedDescription)
    }
}

class DataProviderManager<T, S> {
    
    var delegate: T?
    var model: S?
}
