//
//  BaseCurrencyFilterView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine

protocol BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String)
}

struct BaseCurrencyFilterView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = ViewModel()
    
    @State private var searchText = ""
    @State private var selection: String?
    
    var delegate: BaseCurrencyFilterViewDelegate? // TODO: Fazer a passagem dos dados por reatividade

    var body: some View {
        NavigationView {
            ZStack {
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
        }
    // MARK: - Lista
    private var listCurrenciesView: some View {
        List(viewModel.searchResults, id: \.symbol, selection: $selection) { item in
            HStack {
                Text(item.symbol)
                    .font(.system(size: 14, weight: .bold))
                Text("-")
                    .font(.system(size: 14, weight: .bold))
                Text(item.fullName)
                    .font(.system(size: 14, weight: .semibold))
            }
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
        .navigationTitle("Filtrar moedas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                if let selection {
                    delegate?.didSelected(selection)
                }
                dismiss()
            } label: {
                Text("Ok")
                    .fontWeight(.bold)
            }
        }
    }

    // MARK: - Erro
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

struct BaseCurrencyFilterView_Previews: PreviewProvider {
    static var previews: some View {
        BaseCurrencyFilterView()
    }
}
