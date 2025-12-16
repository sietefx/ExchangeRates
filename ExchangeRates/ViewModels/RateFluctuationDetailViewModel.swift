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
    class ViewModel: ObservableObject {
        
        enum ViewState {
            case start
            case loading
            case success
            case failure(Error?)
        }
        
        @Published var ratesFluctuation = [RateFluctuationModel]()
        @Published var ratesHistorical = [RatesHistoricalModel]()
        @Published var timeRange = TimeRangeEnum.today
        
        @Published var currentState: ViewState = .start
        @Published var baseCurrency: String?
        @Published var fromCurrency: String?
        @Published var rateFluctuation: RateFluctuationModel?
        
        private var fluctuationDataProvider: RatesFluctuationDataProvider?
        private var historicalDataProvider: RatesHistoricalDataProvider?
        private var cancelables = Set<AnyCancellable>()
        
        var title: String {
            guard let baseCurrency = baseCurrency, let fromCurrency = fromCurrency else { return "" }
            return "\(baseCurrency) a \(fromCurrency)"
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
        
        // CORRIJA no ViewModel:
        var yAxisMin: Double {
            // Garantir que nunca retorne NaN ou valores inválidos
            guard !ratesHistorical.isEmpty else { return 0.0 }
            
            let minRate = ratesHistorical.compactMap { $0.endRate }.min() ?? 0.0
            // Verificar se é um número válido
            guard !minRate.isNaN && !minRate.isInfinite else { return 0.0 }
            
            return max(0.0, minRate)
        }

        var yAxisMax: Double {
            // Sempre garantir um valor válido
            guard !ratesHistorical.isEmpty else { return 5000.0 }
            
            let maxRate = ratesHistorical.compactMap { $0.endRate }.max() ?? 0.0
            // Verificar se é um número válido
            guard !maxRate.isNaN && !maxRate.isInfinite else { return 5000.0 }
            
            // Garantir que max > min
            let calculatedMax = max(5000.0, maxRate * 1.05)
            return calculatedMax.isFinite ? calculatedMax : 5000.0
        }

        // ADICIONE esta validação extra:
        var yAxisDomain: ClosedRange<Double> {
            let min = yAxisMin
            let max = yAxisMax
            
            // Garantir que min <= max
            if min > max {
                return 0.0...5000.0
            }
            
            // Garantir que não seja um range inválido
            if min.isNaN || max.isNaN || min.isInfinite || max.isInfinite {
                return 0.0...5000.0
            }
            
            return min...max
        }
        
        init(
                fluctuationDataProvider: RatesFluctuationDataProvider? = nil,
                historicalDataProvider: RatesHistoricalDataProvider? = nil
            ) {
                self.fluctuationDataProvider =
                    fluctuationDataProvider ?? RatesFluctuationDataProvider()

                self.historicalDataProvider =
                    historicalDataProvider ?? RatesHistoricalDataProvider()
            }
        
        func xAxisLabelFormatStyle(for date: Date) -> String {
            switch timeRange {
            case .today: return date.formatter(to: "HH:mm")
            case .thisWeek, .thisMonth: return date.formatter(to: "dd, MMM")
            case .thisSemester: return date.formatter(to: "MMM")
            case .thisYear: return date.formatter(to: "MM, YYYY")
            }
        }
        
        func startStateView(baseCurrency: String, fromCurrency: String, timeRange: TimeRangeEnum) {
            self.baseCurrency = baseCurrency
            self.fromCurrency = fromCurrency
            doFetchData(from: timeRange)
        }
        
        func doFetchData(from timeRange: TimeRangeEnum) {
            currentState = .loading
            ratesFluctuation.removeAll()
            ratesHistorical.removeAll()
            
            withAnimation {
                self.timeRange = timeRange
            }
            doFetchRatesFluctuation()
            doFetchRatesHistorical()
        }
        
        func doComparation(with rateFluctuation: RateFluctuationModel) {
            self.fromCurrency = rateFluctuation.symbol
            self.rateFluctuation = rateFluctuation
            doFetchRatesHistorical()
        }
        
        func doFilter(by currency: String) {
            if let rateFluctuation = ratesFluctuation.filter({ $0.symbol == currency }).first {
                self.fromCurrency = rateFluctuation.symbol
                self.rateFluctuation = rateFluctuation
                doFetchRatesHistorical()
            }
        }
        
        private func doFetchRatesFluctuation() {
            if let baseCurrency {
                let startDate = timeRange.date.toString()
                let endDate = Date().toString()
                fluctuationDataProvider?.fetchFluctuation(by: baseCurrency, from: [], startDate: startDate, endDate: endDate)
                    .receive(on: DispatchQueue.main) // <<< CORREÇÃO AQUI
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.currentState = .success
                        case .failure(let error):
                            print("❌ ERRO NA BUSCA: \(error)")
                            print("❌ DESCRIÇÃO: \(error.localizedDescription)")
                            self.currentState = .failure(error)
                        }
                    }, receiveValue: { rateFluctuation in
                        withAnimation {
                            self.rateFluctuation = rateFluctuation.filter({ $0.symbol == self.fromCurrency }).first
                            self.ratesFluctuation = rateFluctuation.filter({ $0.symbol != self.baseCurrency && $0.symbol != self.fromCurrency }).sorted { $0.symbol < $1.symbol }
                        }
                    }).store(in: &cancelables)
            }
        }
                
        private func doFetchRatesHistorical() {
            if let baseCurrency, let currency = fromCurrency {
                let startDate = timeRange.date.toString()
                let endDate = Date().toString()
                historicalDataProvider?.fetchTimeseries(by: baseCurrency, from: currency, startDate: startDate, endDate: endDate)
                    .receive(on: DispatchQueue.main) // <<< CORREÇÃO AQUI
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.currentState = .success
                        case .failure(let error):
                            print("Falhou!")
                            self.currentState = .failure(error)
                        }
                    }, receiveValue: { ratesHistorical in
                        withAnimation {
                            self.ratesHistorical = ratesHistorical.sorted { $0.period < $1.period }
                        }
                    }).store(in: &cancelables)
            }
        }
    }
}

