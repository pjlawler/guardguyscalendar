//
//  Utilities.swift
//  GuardGuysCalendarEditor
//
//  Created by Patrick Lawler on 10/11/23.
//

import SwiftUI


public func stringDate(from date: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy"
    
    return formatter.string(from: date)
    
}

public func compareDates(apiDate: String, date: Date) -> Bool {
    let apiString = convertApiDateToStringDate(apiDate: apiDate)
    let dateString = stringDate(from: date)
    
    return apiString == dateString
    
}

public func stringUTCDate(from date: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter.string(from: date)
    
}

public func stringUTCTime(from date: Date) -> String {
    
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "hh:mm a"
    
    return formatter.string(from: date)
    
}

public func getFirstDayOfWeek(for date: Date) -> Date {
    let components  = Calendar.current.dateComponents([.weekday], from: date)
    let dayOfWeek   = (components.weekday ?? 0)
    let dayDelta    = dayOfWeek == 1 ? -6 : -(dayOfWeek - 2)
    let delta       = Double(dayDelta * 86_400)
    return date.addingTimeInterval(delta)
   
}

public func todayDayOfWeek() -> Int {
    
    let components  = Calendar.current.dateComponents([.weekday], from: .now)
    return components.weekday ?? 0
    
}

public func newAppointmentDate(date: Date) -> Date {

    // returns at date at 8:00am for the given date
    
    var components = Calendar.current.dateComponents([.month, .year, .day, .hour, .minute], from: date)

    components.minute = 0
    components.hour = 8
    
    return Calendar.current.date(from: components) ?? date
    
    
}

public func dayLabel(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "EEE MM/dd"
    return formatter.string(from: date)
    
}


public func formatStringDate(strDate: String) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "MM-dd-yyyy"
    let date = formatter.date(from: strDate) ?? .now
    formatter.dateFormat = "EEE MM/dd"
    return formatter.string(from: date)
}

public func convertDateToApiString(date: Date) -> String {
    
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    return formatter.string(from: date)
    
}

public func timeSinceApiDate(apiDate: String, date: Date) -> Double {
    let saved = convertApiDateToDate(apiDate: apiDate)
    return date.timeIntervalSince(saved)
}


public func convertApiDateToDate(apiDate: String) -> Date {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    return formatter.date(from: apiDate) ?? Date.now

}


public func convertApiDateToStringTime(apiDate: String, addDuration: Int = 0) -> String {
    
    let formatter = DateFormatter()
    let interval = Double(addDuration / 1000)
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let convertedDate = formatter.date(from: apiDate) {
        formatter.timeZone = .current
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: convertedDate.addingTimeInterval(interval))
    }
   return ""
    
}

public func convertApiDateToStringDate(apiDate: String) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    if let convertedDate = formatter.date(from: apiDate) {
        formatter.timeZone = .current
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: convertedDate)
    }
   return ""
}
