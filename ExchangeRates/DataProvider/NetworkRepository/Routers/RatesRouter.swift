//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

enum RatesRounter {
    
    case fluctuation(base: String, symbols: [String], startDate: String, endDate: String)
    case timeseries(base: String, symbols: [String], startDate: String, endDate: String)
    
    var path: String {
        switch self {
        case .fluctuation:
            return RatesApi.fluctuation
        case .timeseries:
            return RatesApi.timeseries
        }
    }
    
    func asUrlRequest() throws -> URLRequest? {
        guard var url = URL(string: RatesApi.baseUrl + path) else { return nil }
        
        switch self {
        case .fluctuation(let base, let symbols, let startDate, let endDate),
             .timeseries(let base, let symbols, let startDate, let endDate):

            // Query items obrigatórios
            var items: [URLQueryItem] = [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate)
            ]

            // Somente adiciona "symbols" se houver conteúdo
            if !symbols.isEmpty {
                let joinedSymbols = symbols.joined(separator: ",")
                items.append(URLQueryItem(name: "symbols", value: joinedSymbols))
            }

            url.append(queryItems: items)
        }
        
        var request = URLRequest(url: url, timeoutInterval: 60)
        request.httpMethod = HttpMethod.get.rawValue
        request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
        return request
    }
}
