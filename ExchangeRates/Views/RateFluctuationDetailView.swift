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
        .padding(.horizontal, 8)
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
                .font(.system(size: 28, weight: .bold))

            Text(viewModel.changePct.toPercentage(with: true))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(viewModel.changePct.color)
                .background(viewModel.changePct.color.opacity(0.2))

            Text(viewModel.changeDescription)
                .font(.system(size: 18, weight: .semibold))
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
                    .foregroundColor(viewModel.timeRange == .today ? .blue : .gray)
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

//    private func periodButton(_ title: String, _ range: TimeRangeEnum) -> some View {
//        Button {
//            viewModel.doFetchData(from: range)
//        } label: {
//            Text(title)
//                .font(.system(size: 14, weight: .bold))
//                .foregroundColor(viewModel.timeRange == range ? .blue : .gray)
//                .underline(viewModel.timeRange == range)
//        }
//    }

    private var lineChartView: some View {
        Chart(viewModel.ratesHistorical) { item in
            LineMark(
                x: .value("Period", item.period),
                y: .value("Rate", item.endRate)
            )
            .interpolationMethod(.catmullRom)
            
            if !viewModel.hasRates {
                RuleMark(
                    y: .value("Conversão Zero", 0)
                )
                .annotation(position: .overlay, alignment: .center) {
                    Text("Sem valores para exibir a curva.")
                        .font(.footnote)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: viewModel.xAxisStride, count: viewModel.xAxisStrideCount)) { date in
                AxisGridLine()
                AxisValueLabel(viewModel.xAxisLabelFormatStyle(for: date.as(Date.self) ?? Date()))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { rate in
                AxisGridLine()
                AxisValueLabel(rate.as(Double.self)?.formatter(decimalPlaces: 3) ?? 0.0 .formatter(decimalPlaces: 3))
            }
        }
        .chartYScale(domain: viewModel.yAxisMin...viewModel.yAxisMax)
        .frame(height: 260)
        .padding(.trailing, 20)
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
            LazyHGrid(rows: [GridItem(.flexible())]) {
                ForEach(viewModel.ratesFluctuation) { fluctuation in
                    Button {
                        viewModel.doComparation(with: fluctuation)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(fluctuation.symbol) / \(baseCurrency)")
                            Text(fluctuation.endRate.formatter(decimalPlaces: 4))
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray)
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

