//
//  RateApi.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
}

struct RatesApi {
    
    static let baseUrl = "https://api.apilayer.com/exchangerates_data"
    static let apiKey = "Q0g1lU4epY74oehRnHap6z6LIYzWtxnT"
    static let fluctuation = "/fluctuation"
    static let symbols = "/symbols"
    static let timeseries = "/timeseries"

}
