//
//  RateFluctuationDetailView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine
import Charts

struct RateFluctuationDetailView: View {

    @StateObject var viewModel = ViewModel()

    @State var baseCurrency: String
    @State var fromCurrency: String
    @State private var isPresentedBaseCurrencyFilter = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            valuesView
            graphicChartView
            comparationView
        }
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.startStateView(
                baseCurrency: baseCurrency,
                fromCurrency: fromCurrency,
                timeRange: .today
            )}
    }

    // MARK: - Values
    private var valuesView: some View {
        HStack(spacing: 8) {
            Text(viewModel.endRate.formatter(decimalPlaces: 4))
                .font(.system(size: 22, weight: .bold))

            Text(viewModel.changePct.toPercentage(with: true))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(viewModel.changePct.color)
                .background(viewModel.changePct.color.opacity(0.2))

            Text(viewModel.changeDescription)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(viewModel.change.color)

            Spacer()
        }
        .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
    }

    // MARK: - Chart
    private var graphicChartView: some View {
        VStack {
            periodFilterView
            lineChartView
        }
        .padding(.vertical, 8)
    }

    private var periodFilterView: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.doFetchData(from: .today)
            } label: {
                Text("1 dia")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .today ? .blue : .gray)
                    .underline(viewModel.timeRange == .today)
            }
            Button {
                viewModel.doFetchData(from: .thisMonth)
            } label: {
                Text("1 mês")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisMonth ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisMonth)
            }
            Button {
                viewModel.doFetchData(from: .thisSemester)
            } label: {
                Text("6 meses")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisSemester ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisSemester)
            }
            Button {
                viewModel.doFetchData(from: .thisYear)
            } label: {
                Text("1 ano")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(viewModel.timeRange == .thisYear ? .blue : .gray)
                    .underline(viewModel.timeRange == .thisYear)
            }
        }
    }

    private var lineChartView: some View {
        Chart(viewModel.ratesHistorical) { item in
            LineMark(
                x: .value("Period", item.period),
                y: .value("Rate", item.endRate)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Linha de referência horizontal em 5.000 (mantida)
            RuleMark(y: .value("Limite", 5000))
                .foregroundStyle(.gray.opacity(0.3))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
        }
        .chartYScale(domain: viewModel.yAxisMin...viewModel.yAxisMax)
        
        // EIXO Y SIMPLIFICADO - menos grades e números
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 2000)) { value in  // ← Reduzido de 1000 para 2000
                AxisGridLine()
                    .foregroundStyle(.gray.opacity(0.1))  // Grades mais sutis
                AxisValueLabel {
                    if let rate = value.as(Double.self) {
                        Text("\(Int(rate))")
                            .font(.system(size: 9, weight: .regular))  // Fonte menor
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        
        // EIXO X MANTIDO (mas simplificado)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in  // ← Apenas uma marca por semana
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(viewModel.xAxisLabelFormatStyle(for: date))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.1))  // Grade mais sutil
                }
            }
        }
        .frame(height: 280)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Comparação
    private var comparationView: some View {
        VStack(spacing: 8) {
            comparationButtonView
            comparationScrollView
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private var comparationButtonView: some View {
        Button {
            isPresentedBaseCurrencyFilter.toggle()
        } label: {
            Image(systemName: "magnifyingglass")
            Text("Comparar com")
                .font(.system(size: 16))
        }
        .fullScreenCover(isPresented: $isPresentedBaseCurrencyFilter, content: {
            BaseCurrencyFilterView(delegate: self)
        })
        .opacity(viewModel.ratesFluctuation.isEmpty ? 0 : 1)
    }

    private var comparationScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], alignment: .center) {
                ForEach(viewModel.ratesFluctuation) { fluctuation in
                    Button {
                        viewModel.doComparation(with: fluctuation)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(fluctuation.symbol) / \(baseCurrency)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                            Text(fluctuation.endRate.formatter(decimalPlaces: 4))
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            HStack(alignment: .bottom, spacing: 60) {
                                Text(fluctuation.symbol)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text(fluctuation.changePct.toPercentage())
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(fluctuation.changePct.color)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

extension RateFluctuationDetailView: BaseCurrencyFilterViewDelegate {
    func didSelected(_ baseCurrency: String) {
        viewModel.doFilter(by: baseCurrency)
    }
}

struct RateFluctuationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RateFluctuationDetailView(baseCurrency: "BRL", fromCurrency: "USD")
    }
}

