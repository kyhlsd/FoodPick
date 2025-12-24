//
//  DistanceFormatter.swift
//  Presentation
//
//  Created by 김영훈 on 12/25/25.
//

import Foundation

enum DistanceFormatter {
    static func format(_ distance: Float?) -> String {
        guard let distance = distance else { return "0m" }

        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1fkm", km)
        }
    }
}
