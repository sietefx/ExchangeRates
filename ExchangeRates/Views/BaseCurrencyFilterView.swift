//
//  BaseCurrencyFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

struct Symbol: Identifiable, Equatable {
    let id = UUID()
    var symbol: String
    var fullName: String
}

class BaseCurrencyFilterViewModel: ObservableObject {
    @Published var symbols: [Symbol] = [
        Symbol(symbol: "BRL", fullName: "Brazilian Real"),
        Symbol(symbol: "EUR", fullName: "Euro"),
        Symbol(symbol: "GBP", fullName: "British Pound Sterling"),
        Symbol(symbol: "JPY", fullName: "Japanese Yen"),
        Symbol(symbol: "USD", fullName: "US Dollar")
    ]
}

struct BaseCurrencyFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = BaseCurrencyFilterViewModel()
    @State private var searchText = ""
    @State private var selection: String?
    
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
                dismiss()
            } label: {
                Text("Ok")
                    .fontWeight(.bold)
            }
        }
    }
}

struct BaseCurrencyFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BaseCurrencyFilterView()
    }
}
