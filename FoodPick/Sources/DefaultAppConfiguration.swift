//
//  DefaultAppConfiguration.swift
//  FoodPick
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import Core

final class DefaultAppConfiguration: AppConfiguration {
    var kakaoAppKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String else {
            fatalError("KAKAO_APP_KEY not found in Info.plist. Please set it in Secrets.xcconfig")
        }
        return key
    }
}
