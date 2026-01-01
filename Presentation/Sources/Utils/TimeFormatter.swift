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

    /// 24시간 형식의 시간 문자열을 시:분 AM/PM 형식으로 변환합니다.
    /// - Parameter time24: 24시간 형식 문자열 (예: "18:30", "09:00")
    /// - Returns: 시:분 AM/PM 형식 문자열 (예: "6:30 PM", "9:00 AM")
    static func toFullAMPMFormat(from time24: String) -> String {
        let components = time24.split(separator: ":")
        guard let hourString = components.first,
              let hour = Int(hourString),
              components.count > 1 else {
            return time24
        }

        let minute = components[1]
        let isPM = hour >= 12
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(displayHour):\(minute) \(isPM ? "PM" : "AM")"
    }

    /// 24시간 형식의 시간 문자열을 한국어 오전/오후 형식으로 변환합니다.
    /// - Parameter time24: 24시간 형식 문자열 (예: "18:30", "09:00")
    /// - Returns: 한국어 오전/오후 형식 문자열 (예: "오후 6:30", "오전 9:00")
    static func toKoreanAMPMFormat(from time24: String) -> String {
        let components = time24.split(separator: ":")
        guard let hourString = components.first,
              let hour = Int(hourString),
              components.count > 1 else {
            return time24
        }

        let minute = components[1]
        let isPM = hour >= 12
        let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(isPM ? "오후" : "오전") \(displayHour):\(minute)"
    }

    /// Date 객체를 한국어 오전/오후 형식으로 변환합니다.
    /// - Parameter date: 변환할 날짜
    /// - Returns: 한국어 오전/오후 형식 문자열 (예: "오후 6:30", "오전 9:00")
    static func toKoreanAMPMFormat(from date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let time24 = String(format: "%02d:%02d", hour, minute)
        return toKoreanAMPMFormat(from: time24)
    }

    /// 상대적 시간 문자열로 변환합니다.
    /// - 1시간 전까지: "30분 전"
    /// - 하루 전까지: "5시간 전"
    /// - 이틀 전까지: "하루 전"
    /// - 그 이후: "2025년 9월 3일"
    /// - Parameter date: 변환할 날짜
    /// - Returns: 상대적 시간 문자열
    static func toRelativeTimeString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)

        // 음수인 경우 (미래 날짜) 절대값 형식으로 표시
        let absoluteInterval = abs(timeInterval)

        let minutes = Int(absoluteInterval / 60)
        let hours = Int(absoluteInterval / 3600)

        switch absoluteInterval {
        case 0..<3600: // 1시간 전까지
            return "\(minutes)분 전"
        case 3600..<86400: // 하루 전까지
            return "\(hours)시간 전"
        case 86400..<172800: // 이틀 전까지
            return "하루 전"
        default: // 그 이후
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: date)
        }
    }
}
