import Foundation
import SwiftUI
import Combine

extension RatesFluctuationView {

    @MainActor
    class ViewModel: ObservableObject {

        enum ViewState {
            case start
            case loading
            case success
            case failure
        }

        // MARK: - Published State
        @Published var ratesFluctuations: [RateFluctuationModel] = []
        @Published var searchResults: [RateFluctuationModel] = []
        @Published var timeRange: TimeRangeEnum = .today
        @Published var baseCurrency: String = "BRL"
        @Published var currencies = [String]()
        @Published var currentState: ViewState = .start

        // MARK: - Dependencies
        private let dataProvider: RatesFluctuationDataProvider
        private let currencySymbolsDataProvider: CurrencySymbolsDataProvider
        private var cancellables = Set<AnyCancellable>()

        // MARK: - Init
        
        // Inicializador principal para injeção de dependências
        init(
            dataProvider: RatesFluctuationDataProvider,
            currencySymbolsDataProvider: CurrencySymbolsDataProvider
        ) {
            self.dataProvider = dataProvider
            self.currencySymbolsDataProvider = currencySymbolsDataProvider
        }
        
        // Inicializador de conveniência para uso padrão
        convenience init() {
            self.init(
                dataProvider: RatesFluctuationDataProvider(),
                currencySymbolsDataProvider: CurrencySymbolsDataProvider()
            )
        }

        // MARK: - Public Fetch (Chamado pela View - Inicia o fluxo)
        func doFetchRatesFluctuations(timeRange: TimeRangeEnum) {
            
            // Se as moedas já foram carregadas, apenas atualiza o período.
            if !currencies.isEmpty {
                fetchRatesFluctuations(timeRange: timeRange)
                return
            }
            
            // Fluxo inicial: 1. Carregar Símbolos -> 2. Carregar Flutuações
            currentState = .loading
            self.timeRange = timeRange
            
            // 1. Fetch Symbols
            currencySymbolsDataProvider
                .fetchSymbols() // Assume Publisher<[CurrencySymbolModel], Error>
                .receive(on: DispatchQueue.main) // AQUI ESTÁ A CORREÇÃO DE THREAD SAFETY
                .sink { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        print("Failed to fetch symbols: \(error)")
                        self.currentState = .failure
                    }
                } receiveValue: { [weak self] currencySymbols in // O tipo aqui é [CurrencySymbolModel]
                    guard let self else { return }

                    // Acessando no Main Thread: OK
                    let symbols = currencySymbols.compactMap { $0.symbol }
                    self.currencies = symbols.sorted()

                    // 2. Chama a busca de flutuações após carregar os símbolos
                    self.fetchRatesFluctuations(timeRange: timeRange)
                }
                .store(in: &cancellables)
        }
        
        // MARK: - Private Fetch (Carrega apenas as flutuações)
        private func fetchRatesFluctuations(timeRange: TimeRangeEnum) {
             
             guard !self.currencies.isEmpty else {
                 self.currentState = .failure
                 return
             }

             if self.currentState != .loading {
                 currentState = .loading
             }
             
             withAnimation {
                 self.timeRange = timeRange
             }

             let endDate = Date().toString()
             let startDate = timeRange.date.toString()

             dataProvider
                 .fetchFluctuation(
                     by: baseCurrency,
                     from: currencies,
                     startDate: startDate,
                     endDate: endDate
                 )
                 .receive(on: DispatchQueue.main) // Já estava correto
                 .sink { [weak self] completion in
                     guard let self else { return }
                     if case .failure(let error) = completion {
                         print("COMPLETION: fluctuation fetch failed:", error)
                         self.currentState = .failure
                     } else {
                         self.currentState = .success
                     }
                 } receiveValue: { [weak self] ratesFluctuations in
                     guard let self else { return }
                     withAnimation {
                         self.ratesFluctuations = ratesFluctuations.sorted { $0.symbol < $1.symbol }
                         self.searchResults = self.ratesFluctuations
                     }
                 }
                 .store(in: &cancellables)
        }
    }
}
