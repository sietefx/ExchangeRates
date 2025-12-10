//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

enum RatesRounter {
    
    case fluctuation(base: String, symbols: [String], starDate: String, endDate: String)
    case timeseries(base: String, symbols: [String], starDate: String, endDate: String)
    
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
        case .fluctuation(let base, let symbols, let starDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
                URLQueryItem(name: "start_date", value: starDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        case .timeseries(let base, let symbols, let starDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
                URLQueryItem(name: "start_date", value: starDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        }
        
        var request = URLRequest(url: url.appendingPathComponent(path), timeoutInterval: Double.infinity)
        request.httpMethod = HttpMethod.get.rawValue
        request.addValue(RatesApi.apiKey, forHTTPHeaderField: "apikey")
        return request
    }
}
