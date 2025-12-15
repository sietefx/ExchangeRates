//
//  MultiCurrenciesFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

protocol MultiCurrenciesFilterViewDelegate {
    func didSelected(_ currencies: [String])
}

struct MultiCurrenciesFilterView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = ViewModel()
    
    @State private var searchText = ""
    @State private var selection: [String] = []
    
    var delegate: MultiCurrenciesFilterViewDelegate?
    
    var body: some View {
        NavigationView {
            if case .loading = viewModel.currentState {
                ProgressView()
                    .scaleEffect(2.2, anchor: .center)
            } else if case .success = viewModel.currentState {
                listCurrenciesView
            } else if case .failure = viewModel.currentState {
                errorView
            }
        }
        .onAppear {
            viewModel.doFetchCurrencySymbols()
        }
    }
    
    private var listCurrenciesView: some View {
        List(viewModel.searchResults, id: \.symbol) { item in
            Button {
                if selection.contains(item.symbol) {
                    selection.removeAll { $0 == item.symbol }
                } else {
                    selection.append(item.symbol)
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
                        Spacer()
                    }
                    Image(systemName: "checkmark")
                        .opacity(selection.contains(item.symbol) ? 1 : 0)
                    Spacer()
                }
            }
            .foregroundStyle(.primary)
        }
        .searchable(text: $searchText, prompt: "Buscar moeda base")
        .onChange(of: searchText) { searchText in
            if searchText.isEmpty {
                viewModel.searchResults = viewModel.currencySymbols
            } else {
                viewModel.searchResults = viewModel.currencySymbols.filter {
                    $0.symbol.contains(searchText.uppercased()) ||
                    $0.fullName.uppercased().contains(searchText.uppercased())
                }
            }
        }
        .navigationTitle("Filtrar Moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                delegate?.didSelected(selection)
                dismiss()
            } label: {
                Text(selection.isEmpty ? "Cancelar" : "Ok")
                    .fontWeight(.bold)
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.orange)
            
            Text("Não foi possível carregar os símbolos das moedas.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                viewModel.doFetchCurrencySymbols()
            } label: {
                Label("Tentar novamente", systemImage: "arrow.clockwise")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CurrencySelectionFilterView_Previews: PreviewProvider {
        static var previews: some View {
            MultiCurrenciesFilterView()
    }
}
