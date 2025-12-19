//
//  RootFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/19/25.
//

import Foundation
import ComposableArchitecture
import Domain

@Reducer
public struct RootFeature: Sendable {
    // MARK: - State
    @ObservableState
    public enum State {
        case loading
        case loggedIn
        case loggedOut(LoginFeature.State)
    }

    public enum Action {
        case onAppear
        case authChecked(Bool)
        case handleOpenURL(URL)
        case loggedOut(LoginFeature.Action)
        case logout
    }

    public init() {}

    // MARK: - Body
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    // Font 등록
                    await FontRegistration.registerFonts()
                    
                    // Kakao SDK 초기화
                    await authRepository.initializeKakaoSDK()

                    // 토큰 확인
                    let hasAccessToken = try? await tokenRepository.getAccessToken()
                    let hasRefreshToken = try? await tokenRepository.getRefreshToken()
                    let isLoggedIn = hasAccessToken != nil && hasRefreshToken != nil
                    await send(.authChecked(isLoggedIn))
                }

            case let .handleOpenURL(url):
                return .run { _ in
                    _ = await authRepository.handleKakaoOpenURL(url)
                }

            case let .authChecked(isLoggedIn):
                if isLoggedIn {
                    state = .loggedIn
                } else {
                    state = .loggedOut(LoginFeature.State())
                }
                return .none

            case .loggedOut(.loginCompleted):
                state = .loggedIn
                return .none

            case .loggedOut:
                return .none

            case .logout:
                state = .loggedOut(LoginFeature.State())
                return .none
            }
        }
        .ifCaseLet(\.loggedOut, action: \.loggedOut) {
            LoginFeature()
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.tokenRepository) var tokenRepository
    @Dependency(\.authRepository) var authRepository
}
