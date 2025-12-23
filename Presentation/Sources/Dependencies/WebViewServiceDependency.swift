//
//  WebViewServiceDependency.swift
//  Presentation
//
//  Created by 김영훈 on 12/23/25.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {
    // MARK: - WebView Service
    public var webViewService: WebViewService {
        get { self[WebViewServiceKey.self] }
        set { self[WebViewServiceKey.self] = newValue }
    }
}

// MARK: - Keys
private enum WebViewServiceKey: DependencyKey {
    static let liveValue: WebViewService = {
        @Dependency(\.tokenRepository) var tokenRepository
        return WebViewServiceImpl(tokenRepository: tokenRepository)
    }()
}
