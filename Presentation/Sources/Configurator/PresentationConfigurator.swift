//
//  PresentationConfigurator.swift
//  Presentation
//
//  Created by 김영훈 on 1/14/26.
//

import KakaoMapsSDK

public enum PresentationConfigurator {
    public static func configure(appKey: String) {
        SDKInitializer.InitSDK(appKey: appKey)
    }
}
