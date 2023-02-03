//
//
// Product: AITestDemo
// Project: AITestDemo
// Package: AITestDemo
//


import Foundation
enum PostDateFormat {
    
    case serverDateFormat
    case appDateFormat
    
    var text:String {
        switch self {
        case .serverDateFormat :
            return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case .appDateFormat :
            return "E, d MMM yyyy HH:mm:ss a"
        }
    }
}

enum TimeZoneEnum {
    
    case local
    case server
    
    var obj:TimeZone {
        switch self {
        case .local:
            return TimeZone.current
        case .server:
            return TimeZone(abbreviation:"UTC")!
        }
    }
}

struct PostDate {
    
    static func date(fromString stringDate:String ,withFormat format:PostDateFormat , timeZone:TimeZoneEnum = .server) -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.text
        formatter.locale = Locale(identifier: "en_US_POSIX") // For time format.
        formatter.timeZone = timeZone.obj
        
        if let date = formatter.date(from: stringDate){
            return date
        }
        return nil
    }
    
    static func string(fromDate date:Date, withFormat format:PostDateFormat , timeZone:TimeZoneEnum = .local) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.text
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZoneEnum.local.obj //timeZone.obj
        return formatter.string(from: date)
    }
}
