import Foundation
import SwiftUI
import Combine

extension RatesFluctuationView {

    class ViewModel: ObservableObject {

        enum ViewState {
            case start
            case loading
            case success
            case failure
        }

        // MARK: - Published State
        @Published var ratesFluctuations = [RateFluctuationModel]()
        @Published var searchResults = [RateFluctuationModel]()
        @Published var timeRange: TimeRangeEnum = .today
        @Published var baseCurrency: String = "BRL"

        // moedas padrão para permitir fetch inicial
        @Published var currencies = [String]()

        @Published var currentState: ViewState = .start

        // MARK: - Dependencies
        private let dataProvider: RatesFluctuationDataProvider?
        private var cancellables = Set<AnyCancellable>()

        // MARK: - Init
        init(dataProvider: RatesFluctuationDataProvider = RatesFluctuationDataProvider()) {
            self.dataProvider = dataProvider
        }

        func doFetchRatesFluctuations(timeRange: TimeRangeEnum) {
            currentState = .loading
            
            withAnimation {
                self.timeRange = timeRange
            }
            
            let endDate = Date().toString()
            let startDate = timeRange.date.toString()

            dataProvider?
                .fetchFluctuation(
                    by: baseCurrency,
                    from: currencies,
                    startDate: startDate,
                    endDate: endDate
                )
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case . finished:
                        self.currentState = .success
                        case . failure:
                        self.currentState = .failure
                    }
                }, receiveValue: { ratesFluctuations in
                    withAnimation {
                        self.ratesFluctuations = ratesFluctuations.sorted { $0.symbol < $1.symbol }
                        self.searchResults = self.ratesFluctuations
                    }
                })
                .store(in: &cancellables)
        }
    }
}
