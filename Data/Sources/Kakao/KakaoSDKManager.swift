//
//  KakaoSDKManager.swift
//  Data
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth

public enum KakaoSDKManager {
    public static func initialize() {
        KakaoSDK.initSDK(appKey: APIInfos.kakaoKey)
    }

    @MainActor
    public static func handleOpenURL(_ url: URL) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
}
