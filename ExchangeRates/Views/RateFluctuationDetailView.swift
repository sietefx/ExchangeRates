//
//  RateFluctuationDetailView.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import SwiftUI
import Combine
import Charts

class RateFluctuationViewModel: ObservableObject {
    @Published var fluctuations: [RateFluctuationModel] = [
        RateFluctuationModel(symbol: "JPY", change: 0.008, changePct: 0.4175, endRate: 0.1880),
        RateFluctuationModel(symbol: "EUR", change: 0.003, changePct: 0.1564, endRate: 0.1345),
        RateFluctuationModel(symbol: "GBP", change: -0.001, changePct: -0.0943, endRate: 0.1345)
    ]
    @Published var chartComparations: [RateHistoricalModel] = [
        RateHistoricalModel(symbol: "USD", period: "2025-11-13".toDate(), endRate: 0.14537),
        RateHistoricalModel(symbol: "USD", period: "2025-11-12".toDate(), endRate: 0.13334),
        RateHistoricalModel(symbol: "USD", period: "2025-11-11".toDate(), endRate: 0.13453),
        RateHistoricalModel(symbol: "USD", period: "2025-11-10".toDate(), endRate: 0.14667),
    ]
    @Published var timeRange = TimeRangeEnum.today
    
    var hasRates: Bool {
        return chartComparations.filter {$0.endRate > 0}.count > 0
    }
    
    var yAxisMin: Double {
        let min = chartComparations.map(\.endRate).min() ?? 0
        return (min - (min * 0.02))
    }
    var yAxisMax: Double {
        let max = chartComparations.map(\.endRate).max() ?? 0
        return (max + (max * 0.02))
    }
    func xAxisLabelFormatStyle(for date: Date) -> String {
        switch timeRange {
        case .today: return date.formatter(to: "HH:mm")
        case .thisWeek, .thisMonth: return date.formatter(to: "dd, MMM")
        case .thisSemester: return date.formatter(to: "MMM")
        case .thisYear: return date.formatter(to: "MM, YYYY")
        }
    }
}

struct RateFluctuationDetailView: View {
    @StateObject var viewModel = RateFluctuationViewModel()
    @State var baseCurrency: String = "USD"
    @State var rateFluctuation: RateFluctuationModel = RateFluctuationModel(symbol: "EUR", change: 0.003, changePct: 0.1564, endRate: 0.1345)
    @State private var isPresentedBaseCurrencyFilter = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            valuesView
            graphicChartView
            comparationView
        }
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .navigationTitle("BRL a EUR")
    }
    private var valuesView: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(rateFluctuation.endRate.formatter(decimalPlaces: 4))
                .font(.system(size: 28, weight: .bold))
            Text(rateFluctuation.changePct.toPercentage(with: true))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(rateFluctuation.changePct.color)
                .background(rateFluctuation.changePct.color.opacity(0.2))
            Text(rateFluctuation.change.formatter(decimalPlaces: 4, with: true))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(rateFluctuation.change.color)
            Spacer()
        }
        .padding(.init(top: 16, leading: 16, bottom: 16, trailing: 16))
    }
    
    private var graphicChartView: some View {
        VStack {
            periodFilterView
            lineChartView
            
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private var periodFilterView: some View {
        HStack(spacing: 16) {
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
    }
    
    private var lineChartView: some View {
        Chart(viewModel.chartComparations) { item in
            LineMark(
                x: .value("Period", item.period),
                y: .value("Rates", item.endRate)
            )
            .interpolationMethod(.catmullRom)
            if !viewModel.hasRates {
                RuleMark(y: .value("Conversão Zero", 0)
                )
                .annotation(position: .overlay, alignment: .center) {
                    Text("Sem valores nesse período.")
                        .font(.footnote)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { date in
                AxisGridLine()
                AxisValueLabel(viewModel.xAxisLabelFormatStyle(for: date.as(Date.self) ?? Date()))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { rate in
                AxisGridLine()
                AxisValueLabel(rate.as(Double.self)?.formatter(decimalPlaces: 3) ?? 0.0.formatter(decimalPlaces: 3))
            }
        }
        .chartYScale(domain: viewModel.yAxisMin...viewModel.yAxisMax)
        .frame(height: 260)
        .padding(.trailing, 20)
    }
    
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
            BaseCurrencyFilterView()
        })
    }
    
    private var comparationScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], alignment: .center) {
                ForEach(viewModel.fluctuations) { fluctuation in
                    Button {
                        print("Comparação")
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(fluctuation.symbol) / \(baseCurrency)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            Text(fluctuation.endRate.formatter(decimalPlaces: 4))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            HStack(alignment: .bottom, spacing: 60) {
                                Text(fluctuation.symbol)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text(fluctuation.changePct.toPercentage())
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(fluctuation.changePct.color)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

struct RateFluctuationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RateFluctuationDetailView()
    }
}
