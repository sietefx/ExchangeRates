//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

// CurrencyRouter.swift
enum CurrencyRouter {
    
    case symbols
    
    var path: String {
        switch self {
        case .symbols:
            return RatesApi.symbols
        }
    }
    
    func asURLRequest() throws -> URLRequest? {
        // Append the path to the base URL
        guard let url = URL(string: RatesApi.baseUrl + path) else { return nil }
        
        switch self {
        case .symbols:
            var request = URLRequest(url: url, timeoutInterval: Double.infinity)
            request.httpMethod = HttpMethod.get.rawValue
            request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
            return request
        }
    }
}
