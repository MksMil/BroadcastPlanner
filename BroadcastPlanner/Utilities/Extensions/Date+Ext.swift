//
//  Date+Ext.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 23.09.2024.
//

import Foundation

extension Date {
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isSameHour: Bool {
        Calendar.current.compare(self, to: Date(), toGranularity: .hour) == .orderedSame
    }
    
    var isPast: Bool {
        Calendar.current.compare(self, to: Date(), toGranularity: .hour) == .orderedAscending
    }
    var isFuture: Bool {
        Calendar.current.compare(self, to: Date(), toGranularity: .hour) == .orderedDescending
    }
    
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func fetchWeek(_ date: Date = Date()) -> [WeekDay]{
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        var week = [WeekDay]()
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDay)
        
        guard let startOfWeek = weekForDate?.start else { return [] }
        
        (0..<7).forEach { index in
            if let calendarDay = calendar.date(byAdding: .day, value: index, to: startOfWeek){
                week.append(WeekDay(date: calendarDay))
            }
        }
        return week
    }
    
    func fetchNextWeek()->[WeekDay]{
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        guard let nextDate =  calendar.date(byAdding: .weekOfMonth, value: 1, to: startOfDay) else { return [] }
        return fetchWeek(nextDate)
    }
    
    func fetchPreviousWeek()->[WeekDay]{
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        guard let nextDate =  calendar.date(byAdding: .weekOfMonth, value: -1, to: startOfDay) else { return [] }
        return fetchWeek(nextDate)
    }
    
    func isSameToDate(_ date: Date) -> Bool{
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}

struct WeekDay: Identifiable{
    var id: UUID = UUID()
    var date: Date
}
