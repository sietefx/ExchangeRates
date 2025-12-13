//
//  RatesFluctuationView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

struct RatesFluctuationView: View, BaseCurrencyFilterViewDelegate, MultiCurrenciesFilterViewDelegate {
    func didSelected(_ currencies: [String]) {
        viewModel.currencies = currencies
        viewModel.doFetchRatesFluctuations(timeRange: .today)
    }
    
    func didSelected(_ baseCurrency: String) {
        viewModel.baseCurrency = baseCurrency
        viewModel.doFetchRatesFluctuations(timeRange: .today)
    }
        
    @StateObject var viewModel = ViewModel()
    @State private var searchText = ""
    @State private var viewDidLoad = true
    @State private var isPresentendBaseCurrencyFilter = false
    @State private var isPresentendMultiCurrencyFilter = false
    
    var searchResult: [RateFluctuationModel] {
        if searchText.isEmpty {
            return viewModel.ratesFluctuations
        } else {
            return viewModel.ratesFluctuations.filter {
                $0.symbol.contains(searchText.uppercased()) ||
                $0.change.formatter(decimalPlaces: 4).contains(searchText.uppercased()) ||
                $0.changePct.toPercentage().contains(searchText.uppercased()) ||
                $0.endRate.formatter(decimalPlaces: 2).contains(searchText.uppercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                baseCurrencyPeriodFilterView
                ratesFluctuationListView
                Spacer()
            }
            .searchable(text: $searchText)
            .navigationTitle("Conversão de moedas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    isPresentendMultiCurrencyFilter.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .fullScreenCover(isPresented: $isPresentendMultiCurrencyFilter) {
                    MultiCurrenciesFilterView(delegate: self)
                }
            }
        }
        .onAppear {
            if viewDidLoad {
                viewDidLoad.toggle()
                viewModel.doFetchRatesFluctuations(timeRange: .today)
            }
        }
    }
    
    private var baseCurrencyPeriodFilterView: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                isPresentendBaseCurrencyFilter.toggle()
            } label: {
                Text(viewModel.baseCurrency)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 1)
                    )
            }
            .fullScreenCover(isPresented: $isPresentendBaseCurrencyFilter, content: {
                BaseCurrencyFilterView(delegate: self)
            })
            .background(Color(UIColor.lightGray))
            .cornerRadius(8)
            
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .blue : .gray)
                    .underline(viewModel.timeRange == .today)
            }
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .thisWeek)
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisWeek ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisWeek)
            }
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .thisMonth)
            } label: {
                Text("1 Mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisMonth)
            }
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .thisSemester)
            } label: {
                Text("6 Meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisSemester)
            }
            Button {
                viewModel.doFetchRatesFluctuations(timeRange: .thisYear)
            } label: {
                Text("1 Ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisYear)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    // aplicação da search engine
    private var ratesFluctuationListView: some View {
        List(searchResult) { fluctuation in
            NavigationLink(destination: RateFluctuationDetailView(baseCurrency: "BRL", rateFluctuation: fluctuation)) {
                VStack {
                    // centralizar e alinhar objetos
                    HStack(alignment: .center, spacing: 8) {
                        Text("\(fluctuation.symbol) / BRL")
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
                        .padding(.leading, -20)
                        .padding(.trailing, -40)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white)
        }
        .listStyle(.plain)
    }
}

//extension RatesFluctuationView: BaseCurrencyFilterViewDelegate {
//    func didSelected(_ baseCurrency: String) {
//        viewModel.baseCurrency = baseCurrency
//        viewModel.doFetchRatesFluctuations(timeRange: .today)
//    }
//}

#Preview {
    RatesFluctuationView()
}
