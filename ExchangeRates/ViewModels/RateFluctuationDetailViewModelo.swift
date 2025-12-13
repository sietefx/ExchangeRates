//
//  RateFluctuationDetailViewModelo.swift
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
        func success(model: RatesHistoricalModel) {
            DispatchQueue.main.async {
                // Insert or update the incoming historical model in the list, then keep it sorted by period desc
                if let index = self.ratesHistorical.firstIndex(where: { $0.period == model.period }) {
                    self.ratesHistorical[index] = model
                } else {
                    self.ratesHistorical.append(model)
                }
                self.ratesHistorical.sort { $0.period > $1.period }
            }
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
        
        var yAxisMin: Double {
            let min = ratesHistorical.map(\.endRate).min() ?? 0
            return (min - (min * 0.02))
        }
        var yAxisMax: Double {
            let max = ratesHistorical.map(\.endRate).max() ?? 0
            return (max + (max * 0.02))
        }
        func xAxisLabelFormatStyle(for date: Date) -> String {
            switch timeRange {
            case .today: return date.formatter(to: "HH:mm")
            case .thisWeek, .thisMonth: return date.formatter(to: "dd, MMM")
            case .thisSemester: return date.formatter(to: "MMM")
            case .thisYear: return date.formatter(to: "MM, YYYY")
            }
        }
        
        init(fluctuationDataProvider: RatesFluctuationDataProvider = RatesFluctuationDataProvider(),
        historicalDataProvider: RatesHistoricalDataProvider = RatesHistoricalDataProvider()) {
            self.fluctuationDataProvider = fluctuationDataProvider
            self.historicalDataProvider = historicalDataProvider
            
            self.fluctuationDataProvider?.delegate = self
            self.historicalDataProvider?.delegate = self
        }
        
        func startStateView(baseCurrency: String, ratesFluctuation: RateFluctuationModel, timeRange: TimeRangeEnum) {
            self.baseCurrency = baseCurrency
            self.rateFluctuation = ratesFluctuation
            
        }
        
        func doFetchData(from timeRange: TimeRangeEnum) {
            ratesFluctuation.removeAll()
            ratesHistorical.removeAll()
            
            withAnimation {
                self.timeRange = timeRange
            }
        }
        
        
        
        nonisolated func success(model: [RateFluctuationModel]) {
            DispatchQueue.main.async {
                self.rateFluctuation = model.filter({ $0.symbol == self.symbol }).first
                self.ratesFluctuation = model.filter({ $0.symbol != self.baseCurrency }).sorted { $0.symbol < $1.symbol }
            }
        }
        
        nonisolated func success(model: [RatesHistoricalModel]) {
            DispatchQueue.main.async {
                self.ratesHistorical = model.sorted { $0.period > $1.period }
            }
        }
    }
}
