//
//  CurrencyRouter.swift
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
        // 1. Combina URL Base com o Path (/symbols)
        guard let fullURL = URL(string: RatesApi.baseUrl)?.appendingPathComponent(path) else { return nil }
        
        // 2. Cria a Request
        var request = URLRequest(url: fullURL, timeoutInterval: Double.infinity)
        request.httpMethod = HttpMethod.get.rawValue
        
        // 3. CORREÇÃO CRÍTICA: O Header deve ser "apikey" (em minúsculas)
        request.addValue(RatesApi.apikey, forHTTPHeaderField: "apikey") // Minúsculas!
        
        return request
    }
}
