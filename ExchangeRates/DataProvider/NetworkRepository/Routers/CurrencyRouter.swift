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
    
    func asURLRequest() -> URLRequest? {
        guard let url = URL(string: RatesApi.baseUrl) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        switch self {
        case .symbols:
            var request = URLRequest(url: url.appendingPathComponent(path), timeoutInterval: Double.infinity)
            request.httpMethod = HttpMethod.get.rawValue
            request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apiKey")
            return request
        }
    }
}
