//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

enum CurrencyRouter {
    
    case symbol
    
    var path: String {
        switch self {
        case .symbol:
            return RatesApi.symbols
        }
    }
    
    func asURLRequest() throws -> URLRequest? {
        guard let url = URL(string: RatesApi.baseUrl) else { return nil }
        
        switch self {
            case .symbol:
            var request = URLRequest(url: url.appendingPathComponent(path), timeoutInterval: Double.infinity)
            request.httpMethod = HttpMethod.get.rawValue
            request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
            return request
        }
    }
}
