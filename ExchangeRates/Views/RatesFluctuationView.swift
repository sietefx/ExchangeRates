//
//  RatesFluctuationView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

struct RatesFluctuationView: View {
    

    // MARK: - ViewModel
    @StateObject var viewModel = ViewModel()

    // MARK: - UI State
    @State private var searchText = ""
    @State private var viewDidLoad = true
    @State private var isPresentendBaseCurrencyFilter = false
    @State private var isPresentendMultiCurrencyFilter = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                
                if case .loading = viewModel.currentState {
                    ProgressView()
                        .scaleEffect(2.2, anchor: .center)
                } else if case .success = viewModel.currentState {
                    baseCurrencyPeriodFilterView
                    ratesFluctuationListView
                } else if case .failure = viewModel.currentState {
                    errorView
                }
            }
            .searchable(text: $searchText, prompt: "procurar moeda")
            .onChange(of: searchText) { searchText in
                if searchText.isEmpty {
                    viewModel.searchResults = viewModel.ratesFluctuations
                } else {
                    viewModel.searchResults = viewModel.ratesFluctuations.filter {
                        $0.symbol.contains(searchText.uppercased()) ||
                        $0.change.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.changePct.formatter(decimalPlaces: 6).contains(searchText) ||
                        $0.endRate.formatter(decimalPlaces: 6).contains(searchText)
                    }
                }
            }
            .navigationTitle("Conversão de moedas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isPresentendMultiCurrencyFilter.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .fullScreenCover(isPresented: $isPresentendMultiCurrencyFilter) {
                    MultiCurrenciesFilterView()
                }
            }
            .onAppear {                            viewModel.doFetchRatesFluctuations(timeRange: .today)
            }
        }
    }

    // MARK: - Start View
    private var startView: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Selecione as moedas para iniciar")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
    }

    // MARK: - Base Currency + Period Filter
    private var baseCurrencyPeriodFilterView: some View {
        HStack(alignment: .center, spacing: 16) {

            Button {
                isPresentendBaseCurrencyFilter.toggle()
            } label: {
                Text(viewModel.baseCurrency)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 1)
                    )
            }
            .fullScreenCover(isPresented: $isPresentendBaseCurrencyFilter) {
                BaseCurrencyFilterView()
            }
            .background(Color.gray)
            .cornerRadius(8)

            periodButton(title: "1 dia", range: .today)
            periodButton(title: "7 dias", range: .thisWeek)
            periodButton(title: "1 mês", range: .thisMonth)
            periodButton(title: "6 meses", range: .thisSemester)
            periodButton(title: "1 ano", range: .thisYear)
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private func periodButton(title: String, range: TimeRangeEnum) -> some View {
        Button {
            viewModel.doFetchRatesFluctuations(timeRange: range)
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(viewModel.timeRange == range ? .blue : .gray)
                .underline(viewModel.timeRange == range)
        }
    }

    // MARK: - List
    private var ratesFluctuationListView: some View {
        List(viewModel.searchResults) { fluctuation in
            NavigationLink(
                destination: RateFluctuationDetailView(
                    baseCurrency: viewModel.baseCurrency,
                    fromCurrency: fluctuation.symbol
                )
            ) {
                VStack {
                    HStack(spacing: 8) {
                        Text("\(fluctuation.symbol) / \(viewModel.baseCurrency)")
                            .font(.system(size: 14, weight: .medium))

                        Text(fluctuation.endRate.formatter(decimalPlaces: 2))
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        Text(fluctuation.change.formatter(decimalPlaces: 4, with: true))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.change.color)

                        Text("(\(fluctuation.changePct.toPercentage()))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(fluctuation.change.color)
                    }

                    Divider()
                        .padding(.horizontal, -20)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white)
        }
        .listStyle(.plain)
    }

    // MARK: - Error View
    private var errorView: some View {
        VStack(alignment: .center) {
            Spacer()

            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .frame(width: 54, height: 44)
                .padding(.bottom, 4)

            Text("Ocorreu um erro na busca das flutuações das taxas.")
                .font(.headline.bold())
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .today)
            } label: {
                Text("Tentar novamente?")
            }
            .padding(.top, 4)
            Spacer()
        }
        .padding()
    }
}

// Exemplo em RateFluctuationDetailView.swift
#Preview {
    RatesFluctuationView()
}

