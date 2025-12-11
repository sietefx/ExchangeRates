//
//  RateFluctuationViewModel.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 11/12/25.
//

import Foundation
import SwiftUI
import Combine

extension RatesFluctuationView {
    @MainActor class ViewModel: ObservableObject, RateFluctuationDataProviderDelegate {
        func error(message: String) {
            
        }
        
        @Published var ratesFluctuations = [RateFluctuationModel]()
        @Published var timeRange: TimeRangeEnum = .today
        @Published var baseCurrency = "BRL"
        @Published var currencies = [String]()
        
        private let dataProvider: RatesFluctuationDataProvider?
        
        init(dataProvider: RatesFluctuationDataProvider? = nil) {
            if let dataProvider = dataProvider {
                self.dataProvider = dataProvider
            } else {
                // AGORA SIM — este código já está 100% dentro do MainActor
                self.dataProvider = RatesFluctuationDataProvider()
            }

            self.dataProvider?.delegate = self
        }
        
        func doFetchRatesFluctuations(timeRange: TimeRangeEnum) {
            withAnimation {
                self.timeRange = timeRange
            }
            
            let endDate = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
            dataProvider?.fetchFluctuation(by: baseCurrency, from: currencies, startDate: startDate.toString(), endDate: endDate.toString())
        }
        
        func success(model: [RateFluctuationModel]) {
            DispatchQueue.main.async {
                withAnimation {
                    self.ratesFluctuations = model.sorted { $0.symbol < $1.symbol }
                    print("Sucesso! Recebeu \(model.count) moedas.")
                }
            }
        }
    }
}
