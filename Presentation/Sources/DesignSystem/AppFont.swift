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
        let pretendard = "Pretendard Variable"
        let jalnanGothic = "JalnanGothicTTF"

        switch self {
        case .pretendard(let style):
            switch style {
            case .title1: return Font.custom(pretendard, size: 20).weight(.bold)
            case .body1: return Font.custom(pretendard, size: 16).weight(.medium)
            case .body2: return Font.custom(pretendard, size: 14).weight(.medium)
            case .body3: return Font.custom(pretendard, size: 13).weight(.medium)
            case .caption1: return Font.custom(pretendard, size: 12).weight(.regular)
            case .caption2: return Font.custom(pretendard, size: 10).weight(.regular)
            case .caption3: return Font.custom(pretendard, size: 8).weight(.regular)
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
