//
//  RatesRouter.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import Foundation

enum RatesRouter {
    case fluctuation(base: String, symbols: [String], startDate: String, endDate: String)
    case timeseries(base: String, symbol: String, startDate: String, endDate: String)
    
    var path: String {
        switch self {
        case .fluctuation: return RatesApi.fluctuation
        case .timeseries: return RatesApi.timeseries
        }
    }
    
    func asURLRequest() -> URLRequest? {
        // 1. Inicia com a URL base.
        guard var url = URL(string: RatesApi.baseUrl) else { return nil }
        
        // 2. Adiciona os Query Parameters (start_date, end_date, base, symbols)
        switch self {
        case .fluctuation(let base, let symbols, let startDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")),
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        case .timeseries(let base, let symbol, let startDate, let endDate):
            url.append(queryItems: [
                URLQueryItem(name: "base", value: base),
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "start_date", value: startDate),
                URLQueryItem(name: "end_date", value: endDate)
            ])
        }
        
        // 3. Monta a URL final (Base + Path + Query Items)
        let finalURL = url.appendingPathComponent(path)
        
        // 4. Cria a Request
        var request = URLRequest(url: finalURL, timeoutInterval: Double.infinity)
        request.httpMethod = HttpMethod.get.rawValue
        
        // 5. CORREÇÃO CRÍTICA: O Header deve ser "apikey" (em minúsculas)
        request.addValue(RatesApi.apikey, forHTTPHeaderField: "apikey")
        
        return request
    }
}
