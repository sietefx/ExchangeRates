//
//  RatesFluctuationView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

struct Fluctuation: Identifiable {
    var id: UUID = UUID()
    var symbol: String
    var change: Double
    var changePct: Double
    var endRate: Double
}

extension Fluctuation {
    
    static let samples = [
        Fluctuation(symbol: "USD", change: 0.0008, changePct: 0.41765, endRate: 0.18890),
        Fluctuation(symbol: "EUR", change: 0.0003, changePct: 0.15644, endRate: 0.13545),
        Fluctuation(symbol: "GBP", change: -0.0083, changePct: -0.00943, endRate: 0.12345)
    ]
}

class FluctuationViewModel: ObservableObject {
    @Published var fluctuations: [Fluctuation] = Fluctuation.samples
}

struct RatesFluctuationView: View {
    
    @StateObject var viewModel = FluctuationViewModel()
    
    @State private var searchText = ""
    
    var searchResult: [Fluctuation] {
        if searchText.isEmpty {
            return viewModel.fluctuations
        } else {
            return viewModel.fluctuations.filter {
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
                    print("Filtrar moedas")
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
    }
    
    private var baseCurrencyPeriodFilterView: some View {
        HStack(alignment: .center, spacing: 16) {
            Button {
                print("Filtrar moeda base")
            } label: {
                Text("BRL")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 1))
            }
            .background(Color(UIColor.lightGray))
            .cornerRadius(8)
            
            Button {
                print("1 dia")
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                    .underline()
            }
            Button {
                print("7 dias")
            } label: {
                Text("7 dias")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            Button {
                print("1 Mês")
            } label: {
                Text("1 Mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            Button {
                print("6 Meses")
            } label: {
                Text("6 Meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            Button {
                print("1 Ano")
            } label: {
                Text("1 Ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
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

#Preview {
    RatesFluctuationView()
}
