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
struct LoginFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var email = ""
        var password = ""
        
        var isLoggingIn = false
        
        var isLoginEnabled: Bool {
            !email.isEmpty && !password.isEmpty
        }
        
        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<LoginFeature.Alert>?
    }
    
    // MARK: - Action
    enum Action {
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case joinButtonTapped
        case loginCompleted
        case loginFailed(Error)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<LoginFeature.Alert>)
    }
    
    // MARK: - Body
    var body: some ReducerOf<Self> {
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
                        let deviceToken = (try? await getDeviceTokenUseCase.execute()) ?? ""
                        
                        let response = try await loginUseCase.execute(
                            type: .email(email: email, password: password, deviceToken: deviceToken)
                        )
                        
                        try await saveTokensUseCase.execute(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )
                        
                        await send(.loginCompleted)
                    } catch {
                        await send(.loginFailed(error))
                    }
                }
                
            case .kakaoLoginButtonTapped:
                state.isLoggingIn = true
                
                return .run { send in
                    do {
                        let oauthToken = try await kakaoLoginUseCase.execute()
                        let deviceToken = (try? await getDeviceTokenUseCase.execute()) ?? ""
                        
                        let response = try await loginUseCase.execute(
                            type: .kakao(oauthToken: oauthToken, deviceToken: deviceToken)
                        )
                        
                        try await saveTokensUseCase.execute(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )
                        
                        await send(.loginCompleted)
                    } catch {
                        await send(.loginFailed(error))
                    }
                }
                
            case .appleLoginButtonTapped:
                state.isLoggingIn = true
                
                return .run { send in
                    do {
                        let idToken = try await appleLoginUseCase.execute()
                        let deviceToken = (try? await getDeviceTokenUseCase.execute()) ?? ""
                        
                        let response = try await loginUseCase.execute(
                            type: .apple(idToken: idToken, deviceToken: deviceToken)
                        )
                        
                        try await saveTokensUseCase.execute(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )
                        
                        await send(.loginCompleted)
                    } catch {
                        await send(.loginFailed(error))
                    }
                }
                
            case .joinButtonTapped:
                state.destination = .signUp(SignUpFeature.State())
                return .none
                
            case .loginCompleted:
                state.isLoggingIn = false
                return .none
                
            case .loginFailed(let error):
                state.isLoggingIn = false
                state.alert = AlertState {
                    TextState("로그인 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
                
            case .destination:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }
    
    // MARK: - Dependencies
    @Dependency(\.login) var loginUseCase
    @Dependency(\.getDeviceToken) var getDeviceTokenUseCase
    @Dependency(\.saveTokens) var saveTokensUseCase
    @Dependency(\.appleLogin) var appleLoginUseCase
    @Dependency(\.kakaoLogin) var kakaoLoginUseCase
    
    enum Alert: Sendable {}
}

// MARK: - Destinations
extension LoginFeature {
    @Reducer
    enum Destination {
        case signUp(SignUpFeature)
    }
}

extension LoginFeature.Destination.State: Sendable {}
