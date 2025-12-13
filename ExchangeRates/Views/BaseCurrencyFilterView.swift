//
//  BaseCurrencyFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

protocol BaseCurrencyFilterViewDelegate: View {
    func didSelected(_ baseCurrency: String)
}

struct BaseCurrencyFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = ViewModel.create()
    @State private var searchText = ""
    @State private var selection: String?
    @State private var isLoading = false
    
    var delegate: (any BaseCurrencyFilterViewDelegate)?
    
    var searchReults: [CurrencySymbolModel] {
        if searchText.isEmpty {
            return viewModel.currencySymbols
        } else {
            return viewModel.currencySymbols.filter {
                $0.symbol.contains(searchText.uppercased()) || $0.fullName.uppercased().contains(searchText.uppercased())
            }
        }
    }
    // Aqui é onde chama os métodos para renderizar a viewModel
    var body: some View {
            NavigationView {
                ZStack {
                    if isLoading && viewModel.currencySymbols.isEmpty {
                        ProgressView("Carregando moedas...")
                    } else {
                        listCurrenciesView
                    }
                }
            }
            .onAppear {
                isLoading = true
                viewModel.doFetchCurrencySymbols()
                // Simula um tempo de carregamento
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
        }
    
    private var listCurrenciesView: some View {
        List(searchReults, id: \.symbol, selection: $selection) { item in
            HStack {
                Text(item.symbol)
                    .font(.system(size: 14, weight: .bold))
                Text("-")
                    .font(.system(size: 14, weight: .semibold))
                Text(item.fullName)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Filtrar Moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                if let sel = selection {
                    delegate?.didSelected(sel)
                    dismiss()
                }
            } label: {
                Text("Ok")
                    .fontWeight(.bold)
            }
            .disabled(selection == nil)
        }
    }
}

struct BaseCurrencyFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BaseCurrencyFilterView()
    }
}
