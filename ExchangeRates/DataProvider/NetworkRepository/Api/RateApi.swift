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
    static let apiKey = "dUUUjfN20LbWE8QtxEpuIa2HZYHPN25k"
    static let fluctuation = "/fluctuation"
    static let symbols = "/symbols"
    static let timeseries = "/timeseries"

}
