//
//  MultiCurrenciesFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

protocol MultiCurrenciesFilterViewDelegate: View {
    func didSelected(_ currencies: [String])
}

struct MultiCurrenciesFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    @State private var searchText = ""
    @State private var selections: [String] = []
    
    var delegate: (any MultiCurrenciesFilterViewDelegate)?
    
    var searchReults: [CurrencySymbolModel] {
        if searchText.isEmpty {
            return viewModel.currencySymbols
        } else {
            return viewModel.currencySymbols.filter {
                $0.symbol.contains(searchText.uppercased()) || $0.fullName.uppercased().contains(searchText.uppercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            listCurrenciesView
        }
        .onAppear() {
            viewModel.doFetchCurrencySymbols()
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
                delegate?.didSelected(selections)
                dismiss()
            } label: {
                Text(selections.isEmpty ? "Cancelar" : "Ok")
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    MultiCurrenciesFilterView()
}

