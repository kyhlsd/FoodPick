//
//  DateFormat.swift
//  Core
//
//  Created by 김영훈 on 12/16/25.
//

public enum DateFormat {
    case iso8601
    
    var format: String {
        switch self {
        case .iso8601:
            return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        }
    }
}
