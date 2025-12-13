//
//  RateFluctuationDetailViewModel.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 12/12/25.
//

import Foundation
import SwiftUI
import Combine

extension RateFluctuationDetailView {
    @MainActor
    class ViewModel: ObservableObject, RateFluctuationDataProviderDelegate, RatesHistoricalDataProviderDelegate {
// MARK: - DataProviderManagerDelegate (herdado)
        func success(model: Any) {
            // Implementação vazia - os métodos específicos acima tratam os dados
            // Isso evita o preconditionFailure
        }
        
        func errorData(_ provider: DataProviderManagerDelegate?, error: Error) {
            print("Error: \(error.localizedDescription)")
        }
        
        @Published var ratesFluctuation = [RateFluctuationModel]()
        @Published var ratesHistorical = [RatesHistoricalModel]()
        @Published var timeRange = TimeRangeEnum.today
        @Published var baseCurrency: String?
        @Published var rateFluctuation: RateFluctuationModel?
        
        private var fluctuationDataProvider: RatesFluctuationDataProvider?
        private var historicalDataProvider: RatesHistoricalDataProvider?
        
        var title: String {
            return "\(baseCurrency ?? "") a \(symbol)"
        }
        
        var symbol: String {
            return rateFluctuation?.symbol ?? ""
        }
        
        var endRate: Double {
            return rateFluctuation?.endRate ?? 0
        }
        
        var changePct: Double {
            return rateFluctuation?.changePct ?? 0
        }
        
        var change: Double {
            return rateFluctuation?.change ?? 0
        }
        
        var changeDescription: String {
            switch timeRange {
            case .today:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 dia"
            case .thisWeek:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 7 dias"
            case .thisMonth:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 mês"
            case .thisSemester:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 semestre"
            case .thisYear:
                return "\(change.formatter(decimalPlaces: 4, with: true)) 1 ano"
            }
        }
        
        var hasRates: Bool {
            return ratesHistorical.filter {$0.endRate > 0}.count > 0
        }
        
        var xAxisStride: Calendar.Component {
            switch timeRange {
            case .today: return .hour
            case .thisWeek, .thisMonth: return .day
            case .thisSemester, .thisYear: return .month
            }
        }
        
        var xAxisStrideCount: Int {
            switch timeRange {
            case .today: return 6
            case .thisWeek: return 2
            case .thisMonth: return 6
            case .thisSemester: return 2
            case .thisYear: return 3
            }
        }
        
        var yAxisMin: Double {
            let min = ratesHistorical.map(\.endRate).min() ?? 0
            return (min - (min * 0.02))
        }
        var yAxisMax: Double {
            let max = ratesHistorical.map(\.endRate).max() ?? 0
            return (max + (max * 0.02))
        }
        
        @MainActor init(
            fluctuationDataProvider: RatesFluctuationDataProvider? = nil,
            historicalDataProvider: RatesHistoricalDataProvider? = nil
        ) {
            // Instantiate defaults on the main actor to avoid cross-actor default argument evaluation
            self.fluctuationDataProvider = fluctuationDataProvider ?? RatesFluctuationDataProvider()
            self.historicalDataProvider = historicalDataProvider ?? RatesHistoricalDataProvider()
            
            self.fluctuationDataProvider?.delegate = self
            self.historicalDataProvider?.delegate = self
        }
        
        func xAxisLabelFormatStyle(for date: Date) -> String {
            switch timeRange {
            case .today: return date.formatter(to: "HH:mm")
            case .thisWeek, .thisMonth: return date.formatter(to: "dd, MMM")
            case .thisSemester: return date.formatter(to: "MMM")
            case .thisYear: return date.formatter(to: "MM, YYYY")
            }
        }
        
        func startStateView(baseCurrency: String, rateFluctuation: RateFluctuationModel, timeRange: TimeRangeEnum) {
            self.baseCurrency = baseCurrency
            self.rateFluctuation = rateFluctuation
            doFetchData(from: timeRange)
        }
        
        func doFetchData(from timeRange: TimeRangeEnum) {
            ratesFluctuation.removeAll()
            ratesHistorical.removeAll()
            
            withAnimation {
                self.timeRange = timeRange
            }
            doFetchRatesFluctuation()
            doFetchRatesHistorical(by: symbol)
        }
        
        func doComparation(with rateFluctuation: RateFluctuationModel) {
            self.rateFluctuation = rateFluctuation
            doFetchRatesHistorical(by: rateFluctuation.symbol)
        }
        
        func doFilter(by currency: String) {
            if let rateFluctuation = ratesFluctuation.filter({ $0.symbol == currency }).first {
                self.rateFluctuation = rateFluctuation
                doFetchRatesHistorical(by: rateFluctuation.symbol)
            }
        }
        
        private func doFetchRatesFluctuation() {
            if let baseCurrency {
                let startDate = timeRange.date
                let endDate = Date()
                fluctuationDataProvider?.fetchFluctuation(by: baseCurrency, from: [], startDate: startDate.toString(), endDate: endDate.toString())
            }
        }
        
        private func doFetchRatesHistorical(by currency: String) {
            if let baseCurrency {
                let startDate = timeRange.date
                let endDate = Date()
                historicalDataProvider?.fetchTimeseries(by: baseCurrency, from: currency, startDate: startDate.toString(), endDate: endDate.toString())
            }
        }
        // MARK: - RateFluctuationDataProviderDelegate
        func success(model: [RateFluctuationModel]) {
            Task { @MainActor in
                self.rateFluctuation = model.filter({ $0.symbol == self.symbol }).first
                self.ratesFluctuation = model.filter({ $0.symbol != self.baseCurrency }).sorted { $0.symbol < $1.symbol }
            }
        }
        
        func success(model: [RatesHistoricalModel]) {
            Task { @MainActor in
                // 1. FILTRAR: Garante que só pegamos os dados da moeda selecionada (ex: AED)
                // Isso remove as outras 171 moedas que causam o pico de 15 milhões
                let filteredModel = model.filter { $0.symbol == self.symbol }
                
                // 2. ORDENAR: Garante a ordem cronológica correta (Crescente)
                self.ratesHistorical = filteredModel.sorted { $0.period < $1.period }
                
                // Debug para confirmar
                print("Gráfico atualizado com \(self.ratesHistorical.count) pontos para a moeda \(self.symbol)")
                if let first = self.ratesHistorical.first {
                    print("Primeiro valor: \(first.endRate) em \(first.period)")
                }
            }
        }
    }
}
