//
//  ContentView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 14/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button {
                doFetchData()
            } label: {
                Image(systemName: "network")
            }
        }
        .padding()
    }
    
    private func doFetchData() {
        let rateFluctuationDataProvider = RatesFluctuationDataProvider()
        rateFluctuationDataProvider.delegate = self
        rateFluctuationDataProvider.fetchFluctuation(by: "BRL", from: ["USD", "EUR"], starDate:"2025-10-11", endDate: "2025-11-11")
        
        let rateSymbolDataProvider = CurrencySymbolDataProvider()
        rateSymbolDataProvider.delegate = self
        rateSymbolDataProvider.fetchSymbols(by: "BRL", from: ["USD", "EUR"], starDate:"2025-10-11", endDate: "2025-11-11")
        
        let rateHistoricalDataProvider = RatesHistoricalDataProvider()
        rateHistoricalDataProvider.delegate = self
        rateHistoricalDataProvider.fetchTimeseries(by: "BRL", from: ["USD", "EUR"], starDate:"2025-10-11", endDate: "2025-11-11")
    }
}

extension ContentView: RateFluctuationDataProviderDeletegate {
    func success(model: RatesFluctuationObject) {
        print("RateFluctuationModel: \(model)\n\n")
    }
}

extension ContentView: CurrencySymbolDataProviderDeletegate {
    func success(model: CurrencySymbolObject) {
        print("CurrencySymbolModel: \(model)\n\n")
    }
}

extension ContentView: RatesHistoricalDataProviderDeletegate {
    func success(model: RatesHistoricalObject) {
        print("RatesHistoricalModel: \(model)\n\n")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
