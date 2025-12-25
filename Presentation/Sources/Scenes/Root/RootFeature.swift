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
struct RootFeature: Sendable {
    // MARK: - State
    @ObservableState
    enum State: Sendable {
        case loading
        case loggedIn(TabBarFeature.State)
        case loggedOut(LoginFeature.State)
    }
    
    enum Action {
        case onAppear
        case authChecked(Bool)
        case handleOpenURL(URL)
        case loggedIn(TabBarFeature.Action)
        case loggedOut(LoginFeature.Action)
        case logout
        case shouldNavigateToLogin
    }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
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
                    
                    // 로그인 화면 이동 Notification 구독
                    for await _ in NotificationCenter.default.notifications(named: .shouldNavigateToLogin) {
                        await send(.shouldNavigateToLogin)
                    }
                }
                
            case let .handleOpenURL(url):
                return .run { _ in
                    _ = await authRepository.handleKakaoOpenURL(url)
                }
                
            case let .authChecked(isLoggedIn):
                if isLoggedIn {
                    state = .loggedIn(TabBarFeature.State())
                } else {
                    state = .loggedOut(LoginFeature.State())
                }
                return .none
                
            case .shouldNavigateToLogin:
                // 토큰 만료 또는 유효하지 않은 토큰 - 로그인 화면으로 이동
                return .run { [state] send in
                    // 이미 로그아웃 상태가 아닌 경우에만 토큰 삭제 및 로그아웃 처리
                    if case .loggedIn = state {
//                        try? await tokenRepository.deleteTokens()
                        await send(.logout)
                    }
                }
                
            case .loggedIn:
                return .none
                
            case .loggedOut(.loginCompleted):
                state = .loggedIn(TabBarFeature.State())
                return .none
                
            case .loggedOut:
                return .none
                
            case .logout:
                state = .loggedOut(LoginFeature.State())
                return .none
            }
        }
        .ifCaseLet(\.loggedIn, action: \.loggedIn) {
            TabBarFeature()
        }
        .ifCaseLet(\.loggedOut, action: \.loggedOut) {
            LoginFeature()
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.tokenRepository) var tokenRepository
    @Dependency(\.authRepository) var authRepository
}
