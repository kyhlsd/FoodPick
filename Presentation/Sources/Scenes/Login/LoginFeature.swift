//
//  LoginFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State {
        var email: String = ""
        var password: String = ""
        @Presents var destination: Destination.State?

        var isLoginEnabled: Bool {
            !email.isEmpty && !password.isEmpty
        }
        
        public init() {}
    }

    public enum Action {
        case emailChanged(String)
        case passwordChanged(String)
        case loginButtonTapped
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case joinButtonTapped
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
                // TODO: 로그인 로직 구현
                return .none

            case .kakaoLoginButtonTapped:
                // TODO: 카카오 로그인 로직 구현
                return .none

            case .appleLoginButtonTapped:
                // TODO: 애플 로그인 로직 구현
                return .none

            case .joinButtonTapped:
                state.destination = .signUp(SignUpFeature.State())
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension LoginFeature {
    @Reducer
    public enum Destination {
        case signUp(SignUpFeature)
    }
}
