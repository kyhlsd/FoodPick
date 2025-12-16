//
//  DateFormatterProvider.swift
//  Core
//
//  Created by 김영훈 on 12/16/25.
//

import Foundation

public enum DateFormatterProvider {
    
    public static var iso8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
    public static func formatter(_ format: DateFormat, timeZone: TimeZone = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = timeZone
        formatter.dateFormat = format.format
        return formatter
    }
    
}
