//
//  RatesHistoricalDataProvider.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation
import Combine

protocol RatesHistoricalDataProviderProtocol {
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String) -> AnyPublisher<[RatesHistoricalModel], Error>
}

class RatesHistoricalDataProvider: RatesHistoricalDataProviderProtocol {
    
    private let ratesStore: RatesStore
    
    init(ratesStore: RatesStore = RatesStore()) {
        self.ratesStore = ratesStore
    }
    
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String) -> AnyPublisher<[RatesHistoricalModel], Error> {
        return Future { promise in
            self.ratesStore.fetchTimeseries(by: base, from: symbol, startDate: startDate, endDate: endDate) { result, error in
                DispatchQueue.main.async {
                    if let error {
                        return promise(.failure(error))
                    }
                    
                    guard let rates = result?.rates else {
                        return promise(.failure(NSError(
                            domain: "RatesAPI",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Resposta sem rates."]
                        )))
                    }
                    
                    let ratesHistorical = rates.flatMap({ (key, rates) -> [RatesHistoricalModel] in
                        return rates.map { RatesHistoricalModel(symbol: $0, period: key.toDate(), endRate: $1) }
                    })
                    return promise(.success(ratesHistorical))
                }
            }
        }.eraseToAnyPublisher()
    }
}
