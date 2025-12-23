//
//  AppFont.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import SwiftUI

enum AppFont {
    
    enum Pretendard {
        case title1, body1, body2, body3, caption1, caption2, caption3
        
        var fontSize: CGFloat {
            switch self {
            case .title1: return 20
            case .body1: return 16
            case .body2: return 14
            case .body3: return 13
            case .caption1: return 12
            case .caption2: return 10
            case .caption3: return 8
            }
        }
    }

    struct PretendardStyle {
        let size: Pretendard
        let weight: Weight

        enum Weight {
            case bold, semiBold, medium, regular

            var fontName: String {
                switch self {
                case .bold: return "Pretendard-Bold"
                case .semiBold: return "Pretendard-SemiBold"
                case .medium: return "Pretendard-Medium"
                case .regular: return "Pretendard-Regular"
                }
            }
        }
    }

    enum JalnanGothic {
        case title1, body1, caption1
        
        var fontSize: CGFloat {
            switch self {
            case .title1: return 24
            case .body1: return 20
            case .caption1: return 14
            }
        }
    }
}

extension Font {
    static func pretendard(size: AppFont.Pretendard, weight: AppFont.PretendardStyle.Weight) -> Font {
        return Font.custom(weight.fontName, size: size.fontSize)
    }
    
    static func jalnan(_ style: AppFont.JalnanGothic) -> Font {
        return Font.custom("JalnanGothicTTF", size: style.fontSize)
    }
}
