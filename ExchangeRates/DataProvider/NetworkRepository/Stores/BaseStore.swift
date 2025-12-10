//
//  BaseStore.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 02/12/25.
//

import Foundation

class BaseStore {
    
    let error = NSError(domain: "", code: 901, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]) as Error
    
    struct RateResult<Rates: Codable>: Codable {
        var base: String?
        var success: Bool = false
        var rates: Rates?
        
        init(data: Data?, response: URLResponse?) throws {
            guard let data = data, let response = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: 901, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]) as Error
            }
            if let url = response.url?.absoluteString,
               let json = String(data: data, encoding: .utf8) {
                print("\(response.statusCode): \(url)")
                print("\(json)")
            }
            self = try JSONDecoder().decode(RateResult.self, from: data)
        }
    }
    struct symbolResult: Codable {
        var base: String?
        var success: Bool = false
        var symbols: CurrencySymbolObject?
        
        init(data: Data?, response: URLResponse?) throws {
            guard let data = data, let response = response as? HTTPURLResponse else {
                throw NSError(domain: "", code: 901, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]) as Error
            }
            if let url = response.url?.absoluteString,
               let json = String(data: data, encoding: .utf8) {
                print("\(response.statusCode): \(url)")
                print("\(json)")
            }
            self = try JSONDecoder().decode(symbolResult.self, from: data)
        }
    }
}
 
