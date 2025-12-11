//
//  RateStore.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 03/12/25.
//

import Foundation

protocol RateStoreProtocol {
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String) async throws -> RatesFluctuationObject
    func fetchTimeseries(by base: String, from symbols: [String], startDate: String, endDate: String) async throws -> RatesHistoricalObject
}

class  RatesStore: BaseStore, RateStoreProtocol {
    
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String) async throws -> RatesFluctuationObject {
        guard let urlRequest = try RatesRounter.fluctuation(base: base, symbols: symbols, startDate: startDate, endDate: endDate).asUrlRequest() else {
            throw error
        }
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let rates = try RateResult<RatesFluctuationObject>(data: data, response: response).rates else {
            throw error
        }
        return rates
    }
    func fetchTimeseries(by base: String, from symbols: [String], startDate: String, endDate: String) async throws -> RatesHistoricalObject {
        guard let urlRequest = try RatesRounter.timeseries(base: base, symbols: symbols, startDate: startDate, endDate: endDate).asUrlRequest() else {
            throw error
        }
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let rates = try RateResult<RatesHistoricalObject>(data: data, response: response).rates else {
            throw error
        }
        return rates
    }
}
