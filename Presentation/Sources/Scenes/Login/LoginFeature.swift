//
//  LoginFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct LoginFeature: Sendable {
    @ObservableState
    public struct State {
        var email = ""
        var password = ""
        
        var isLoggingIn = false

        var isLoginEnabled: Bool {
            !email.isEmpty && !password.isEmpty
        }
        
        @Presents var destination: Destination.State?
        
        public init() {}
    }

    @Dependency(\.login) var loginUseCase
    @Dependency(\.getDeviceToken) var getDeviceTokenUseCase
    @Dependency(\.saveTokens) var saveTokensUseCase
    
    public enum Action {
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case joinButtonTapped
        case loginCompleted
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none

            case let .passwordChanged(password):
                state.password = password
                return .none

            case .loginButtonTapped:
                let email = state.email
                let password = state.password
                state.isLoggingIn = true
                
                return .run { send in
                    do {
                        let deviceToken = try await getDeviceTokenUseCase.execute()
                        
                        let response = try await loginUseCase.execute(
                            type: .email(email: email, password: password, deviceToken: deviceToken)
                        )
                        
                        try await saveTokensUseCase.execute(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )
                        
                        await send(.loginCompleted)
                    } catch {
                        await send(.loginCompleted)
                    }
                }

            case .kakaoLoginButtonTapped:
                // TODO: 카카오 로그인 로직 구현
                return .none

            case .appleLoginButtonTapped:
                // TODO: 애플 로그인 로직 구현
                return .none

            case .joinButtonTapped:
                state.destination = .signUp(SignUpFeature.State())
                return .none
                
            case .loginCompleted:
                state.isLoggingIn = false
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Destinations
extension LoginFeature {
    @Reducer
    public enum Destination {
        case signUp(SignUpFeature)
    }
}
