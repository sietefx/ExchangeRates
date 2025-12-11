//
//  MultiCurrenciesFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

class MultiCurrenciesFilterViewModel: ObservableObject {
    @Published var symbols: [Symbol] = [
        Symbol(symbol: "BRL", fullName: "Brazilian Real"),
        Symbol(symbol: "EUR", fullName: "Euro"),
        Symbol(symbol: "GBP", fullName: "British Pound Sterling"),
        Symbol(symbol: "JPY", fullName: "Japanese Yen"),
        Symbol(symbol: "USD", fullName: "United States Dollar"),
    ]
}

struct MultiCurrenciesFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = MultiCurrenciesFilterViewModel()
    @State private var searchText = ""
    @State private var selections: [String] = []
    
    var searchReults: [Symbol] {
        if searchText.isEmpty {
            return viewModel.symbols
        } else {
            return viewModel.symbols.filter {
                $0.symbol.contains(searchText.uppercased()) || $0.fullName.uppercased().contains(searchText.uppercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            listCurrenciesView
        }
    }
    private var listCurrenciesView: some View {
        List(searchReults, id: \.symbol) { item in
            Button {
                if selections.contains(item.symbol) {
                    selections.removeAll { $0 == item.symbol }
                } else {
                    selections.append(item.symbol)
                }
            } label: {
                HStack {
                    HStack {
                        Text(item.symbol)
                            .font(.system(size: 14, weight: .bold))
                        Text("-")
                            .font(.system(size: 14, weight: .semibold))
                        Text(item.fullName)
                            .font(.system(size: 14, weight: .semibold))
                        // adiciona um espaço entre o texto e o checkmark
                        Spacer()
                    }
                    // Aqui coloca sinais de checagem com a lógica de select/deselect
                    Image(systemName: "checkmark")
                        .opacity(selections.contains(item.symbol) ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5), value: selections)
                    Spacer()
                }
                .foregroundColor(.primary)
            }
            
            
            
        }
        .searchable(text: $searchText)
        .navigationTitle("Filtrar Moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                dismiss()
            } label: {
                Text("Ok")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    MultiCurrenciesFilterView()
}

