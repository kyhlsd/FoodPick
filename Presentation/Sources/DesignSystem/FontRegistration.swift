//
//  FontRegistration.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import UIKit
import CoreText

@MainActor
final class FontRegistration {
    private static var isRegistered = false

    static func registerFonts() {
        guard !isRegistered else { return }

        let fonts = [
            // Pretendard Static Fonts
            ("Pretendard-Regular", "otf"),
            ("Pretendard-Medium", "otf"),
            ("Pretendard-SemiBold", "otf"),
            ("Pretendard-Bold", "otf"),
            // Jalnan Gothic
            ("JalnanGothicTTF", "ttf")
        ]

        let bundle = Bundle(for: FontRegistration.self)

        for (fontName, ext) in fonts {
            if let fontURL = bundle.url(forResource: fontName, withExtension: ext) {
                registerFont(url: fontURL, name: fontName)
            }
        }

        isRegistered = true
    }

    private static func registerFont(url: URL, name: String) {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(fontDataProvider) else {
            return
        }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}
