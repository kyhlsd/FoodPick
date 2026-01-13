//
//  DataConfigurator.swift
//  Data
//
//  Created by 김영훈 on 1/13/26.
//

import FirebaseCore
import FirebaseMessaging
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

public enum DataConfigurator {
    public static func configure() {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: APIInfos.kakaoKey)
    }
}
