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
        
        // MARK: - RateFluctuationDataProviderDelegate
        func success(model: [RateFluctuationModel]) {
            Task { @MainActor in
                withAnimation {
                    self.ratesFluctuations = model.sorted { $0.symbol < $1.symbol }
                    print("Sucesso! Recebeu \(model.count) moedas.")
                    print("Moedas recebidas: \(model.map { $0.symbol })")
                }
            }
        }
        
        // MARK: - DataProviderManagerDelegate (protocolo pai)
        func success(model: Any) {
            // Desembrulhe para o tipo específico
            if let fluctuations = model as? [RateFluctuationModel] {
                success(model: fluctuations) // Chama o método específico
            }
        }
        
        func errorData(_ provider: DataProviderManagerDelegate?, error: Error) {
            print("Error fetching rate fluctuations: \(error.localizedDescription)")
            // Aqui você pode adicionar lógica para mostrar erro na UI
        }
        
        // Remova ou renomeie este método para evitar conflito
        func error(message: String) {
            print("Error: \(message)")
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
