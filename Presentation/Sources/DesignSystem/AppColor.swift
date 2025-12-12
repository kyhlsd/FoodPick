//
//  AppColor.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import SwiftUI

enum AppColor {
    
    enum Family {
        case brand(Brand)
        case gray(Gray)
    }
    
    enum Brand {
        case blackSprout
        case deepSprout
        case brightSprout
        case brightForsythia
    }
    
    enum Gray {
        case gray0
        case gray15
        case gray30
        case gray45
        case gray60
        case gray75
        case gray90
        case gray100
    }
}

extension AppColor.Family {
    var color: Color {
        switch self {
        case .brand(let style):
            switch style {
            case .blackSprout: return Color(hex: "#82957B")
            case .deepSprout: return Color(hex: "#B7C8B1")
            case .brightSprout: return Color(hex: "#E0E4D9")
            case .brightForsythia: return Color(hex: "#FDC020")
            }
            
        case .gray(let style):
            switch style {
            case .gray0: return Color(hex: "#FFFFFF")
            case .gray15: return Color(hex: "#F9F9F9")
            case .gray30: return Color(hex: "#EAEAEA")
            case .gray45: return Color(hex: "#D8D6D7")
            case .gray60: return Color(hex: "#ABABAE")
            case .gray75: return Color(hex: "#6A6A6E")
            case .gray90: return Color(hex: "#434347")
            case .gray100: return Color(hex: "#0B0B0B")
            }
        }
    }
}

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexFormatted = hexFormatted.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
    
    static func custom(_ appColor: AppColor.Family) -> Self {
        return appColor.color
    }
}

extension ShapeStyle where Self == Color {
    static func custom(_ appColor: AppColor.Family) -> Color {
        return appColor.color
    }
}
