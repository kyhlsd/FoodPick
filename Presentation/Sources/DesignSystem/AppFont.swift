//
//  AppFont.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import SwiftUI

enum AppFont {

    enum Family {
        case pretendard(Pretendard)
        case jalnan(JalnanGothic)
    }

    enum Pretendard {
        case title1, body1, body2, body3, caption1, caption2, caption3
    }

    enum JalnanGothic {
        case title1, body1, caption1
    }
}

extension AppFont.Family {
    var font: Font {
        let jalnanGothic = "JalnanGothicTTF"

        switch self {
        case .pretendard(let style):
            switch style {
            case .title1: return Font.custom("Pretendard-Bold", size: 20)
            case .body1: return Font.custom("Pretendard-Bold", size: 16)
            case .body2: return Font.custom("Pretendard-Medium", size: 14)
            case .body3: return Font.custom("Pretendard-Medium", size: 13)
            case .caption1: return Font.custom("Pretendard-SemiBold", size: 12)
            case .caption2: return Font.custom("Pretendard-Regular", size: 10)
            case .caption3: return Font.custom("Pretendard-Regular", size: 8)
            }

        case .jalnan(let style):
            switch style {
            case .title1: return Font.custom(jalnanGothic, size: 24)
            case .body1: return Font.custom(jalnanGothic, size: 20)
            case .caption1: return Font.custom(jalnanGothic, size: 14)
            }
        }
    }
}

extension Font {
    static func custom(_ appFont: AppFont.Family) -> Self {
        return appFont.font
    }
}
