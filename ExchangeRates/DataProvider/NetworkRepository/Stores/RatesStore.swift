//
//  RatesStore.swift
//  ExchangeRates
//

import Foundation

protocol RateStoreProtocol: GenericStoreProtocol {
    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String,
                          completion: @escaping completion<RateObject<RatesFluctuationObject>?>)
    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String,
                         completion: @escaping completion<RateObject<RatesHistoricalObject>?>)
}

class RatesStore: GenericStoreRequest, RateStoreProtocol {

    func fetchFluctuation(by base: String, from symbols: [String], startDate: String, endDate: String,
                          completion: @escaping completion<RateObject<RatesFluctuationObject>?>) {
        
        guard let urlRequest = RatesRouter
            .fluctuation(base: base, symbols: symbols, startDate: startDate, endDate: endDate)
            .asURLRequest()
        else {
            return completion(nil, URLError(.badURL))
        }

        request(urlRequest: urlRequest, completion: completion)
    }

    func fetchTimeseries(by base: String, from symbol: String, startDate: String, endDate: String,
                         completion: @escaping completion<RateObject<RatesHistoricalObject>?>) {

        guard let urlRequest = RatesRouter
            .timeseries(base: base, symbol: symbol, startDate: startDate, endDate: endDate)
            .asURLRequest()
        else {
            return completion(nil, error)
        }

        request(urlRequest: urlRequest, completion: completion)
    }
}
