//
//  TimeRangeEnum.swift
//  ExchangeRates
//
//  Created by Gabriel Felix on 10/12/25.
//

import Foundation

enum TimeRangeEnum {
    case today
    case thisWeek
    case thisMonth
    case thisSemester
    case thisYear
    
    var date: Date {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                return calendar.date(byAdding: .day, value: -1, to: now) ?? now
            case .thisWeek:
                return calendar.date(byAdding: .day, value: -6, to: now) ?? now // 6 dias atrás
            case .thisMonth:
                return calendar.date(byAdding: .month, value: -1, to: now) ?? now // 1 mês atrás
            case .thisSemester:
                return calendar.date(byAdding: .month, value: -6, to: now) ?? now // 6 meses atrás
            case .thisYear:
                return calendar.date(byAdding: .year, value: -1, to: now) ?? now // 1 ano atrás
        }
    }
}
