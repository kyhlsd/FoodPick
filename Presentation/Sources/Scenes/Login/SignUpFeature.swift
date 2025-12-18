//
//  SignUpFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import Foundation
import ComposableArchitecture
import Domain

@Reducer
public struct SignUpFeature {
    @ObservableState
    public struct State {
        var email: String = ""
        var password: String = ""
        var passwordConfirm: String = ""
        var isEmailChecked: Bool = false
        var isEmailDuplicate: Bool = false

        var emailError: String?
        var passwordError: String?
        var passwordConfirmError: String?

        var isSignUpEnabled: Bool {
            !email.isEmpty &&
            !password.isEmpty &&
            !passwordConfirm.isEmpty &&
            emailError == nil &&
            passwordError == nil &&
            passwordConfirmError == nil &&
            isEmailChecked &&
            !isEmailDuplicate
        }

        var isEmailCheckEnabled: Bool {
            !email.isEmpty && emailError == nil
        }

        var emailValidationMessage: String? {
            if let emailError = emailError {
                return emailError
            }
            guard isEmailChecked else { return nil }
            return isEmailDuplicate
                ? "이미 사용 중인 이메일입니다"
                : "사용 가능한 이메일입니다"
        }

        var passwordValidationMessage: String? {
            passwordError
        }

        var passwordConfirmMessage: String? {
            passwordConfirmError
        }

        var isEmailError: Bool {
            emailError != nil || isEmailDuplicate
        }

        public init() {}
    }

    @Dependency(\.signUpInputValidation) var validationUseCase

    public enum Action {
        case emailChanged(String)
        case passwordChanged(String)
        case passwordConfirmChanged(String)
        case checkEmailButtonTapped
        case signUpButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                state.email = email
                state.isEmailChecked = false

                // 이메일 유효성 검증
                if email.isEmpty {
                    state.emailError = nil
                } else {
                    switch validationUseCase.validateEmail(email: email) {
                    case .success:
                        state.emailError = nil
                    case .failure(let error):
                        state.emailError = error.errorDescription
                    }
                }

                return .none

            case let .passwordChanged(password):
                state.password = password

                // 비밀번호 유효성 검증
                if password.isEmpty {
                    state.passwordError = nil
                } else {
                    switch validationUseCase.validatePassword(password: password) {
                    case .success:
                        state.passwordError = nil
                    case .failure(let error):
                        state.passwordError = error.errorDescription
                    }
                }

                // 비밀번호 확인 검증
                if !state.passwordConfirm.isEmpty {
                    if password.isEmpty {
                        state.passwordConfirmError = nil
                    } else {
                        switch validationUseCase.confirmPassword(password: password, confirm: state.passwordConfirm) {
                        case .success:
                            state.passwordConfirmError = nil
                        case .failure(let error):
                            state.passwordConfirmError = error.errorDescription
                        }
                    }
                }

                return .none

            case let .passwordConfirmChanged(passwordConfirm):
                state.passwordConfirm = passwordConfirm

                // 비밀번호 확인 검증
                if passwordConfirm.isEmpty {
                    state.passwordConfirmError = nil
                } else {
                    switch validationUseCase.confirmPassword(password: state.password, confirm: passwordConfirm) {
                    case .success:
                        state.passwordConfirmError = nil
                    case .failure(let error):
                        state.passwordConfirmError = error.errorDescription
                    }
                }

                return .none

            case .checkEmailButtonTapped:
                // TODO: 이메일 중복 체크 API 호출
                state.isEmailChecked = true
                state.isEmailDuplicate = false
                return .none

            case .signUpButtonTapped:
                // TODO: 회원가입 API 호출
                return .none
            }
        }
    }
}

// MARK: - Dependency
extension DependencyValues {
    var signUpInputValidation: SignUpInputValidationUseCase {
        get { self[SignUpInputValidationKey.self] }
        set { self[SignUpInputValidationKey.self] = newValue }
    }
}

private enum SignUpInputValidationKey: DependencyKey {
    static let liveValue: SignUpInputValidationUseCase = SignUpInputValidationUseCaseImpl()
}
