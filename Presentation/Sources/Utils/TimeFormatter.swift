//
//  TimeFormatter.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import Foundation

enum TimeFormatter {
    /// 24시간 형식의 시간 문자열을 AM/PM 형식으로 변환합니다.
    /// - Parameter time24: 24시간 형식 문자열 (예: "18:00", "09:30")
    /// - Returns: AM/PM 형식 문자열 (예: "6 PM", "9 AM")
    static func toAMPMFormat(from time24: String) -> String {
        let components = time24.split(separator: ":")
        guard let hourString = components.first,
              let hour = Int(hourString) else {
            return time24
        }

        let isPM = hour >= 12
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(displayHour) \(isPM ? "PM" : "AM")"
    }
}
