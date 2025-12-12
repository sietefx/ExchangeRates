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
            print("Error: \(message)")
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
                self.dataProvider = RatesFluctuationDataProvider()
            }
            self.dataProvider?.delegate = self
        }
        
        func doFetchRatesFluctuations(timeRange: TimeRangeEnum) {
            withAnimation {
                self.timeRange = timeRange
            }
            
            let endDate = Date()
            let startDate = getStartDate(for: timeRange, from: endDate)
            
            print("Fetching fluctuations for timeRange: \(timeRange)")
            print("Start Date: \(startDate.toString())")
            print("End Date: \(endDate.toString())")
            print("Base: \(baseCurrency)")
            print("Symbols: \(currencies.joined(separator: ", "))")
            
            dataProvider?.fetchFluctuation(
                by: baseCurrency,
                from: currencies,
                startDate: startDate.toString(),
                endDate: endDate.toString()
            )
        }
        
        private func getStartDate(for timeRange: TimeRangeEnum, from endDate: Date) -> Date {
            let calendar = Calendar.current
            
            switch timeRange {
            case .today:
                return calendar.date(byAdding: .day, value: -1, to: endDate) ?? endDate
            case .thisWeek:
                return calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
            case .thisMonth:
                return calendar.date(byAdding: .month, value: -1, to: endDate) ?? endDate
            case .thisSemester:
                return calendar.date(byAdding: .month, value: -6, to: endDate) ?? endDate
            case .thisYear:
                return calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
            }
        }
        
        func success(model: [RateFluctuationModel]) {
            DispatchQueue.main.async {
                withAnimation {
                    self.ratesFluctuations = model.sorted { $0.symbol < $1.symbol }
                    print("Sucesso! Recebeu \(model.count) moedas.")
                    print("Moedas recebidas: \(model.map { $0.symbol })")
                }
            }
        }
        
        // Método para adicionar/remover moedas
        func updateCurrencies(_ newCurrencies: [String]) {
            self.currencies = newCurrencies
            // Atualiza os dados com as novas moedas
            doFetchRatesFluctuations(timeRange: self.timeRange)
        }
        
        // Método para alterar a moeda base
        func updateBaseCurrency(_ newBaseCurrency: String) {
            self.baseCurrency = newBaseCurrency
            // Atualiza os dados com a nova moeda base
            doFetchRatesFluctuations(timeRange: self.timeRange)
        }
    }
}
