//
//  SignUpFeature.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
struct SignUpFeature: Sendable {
    // MARK: - State
    @ObservableState
    struct State: Sendable {
        var email = ""
        var password = ""
        var passwordConfirm = ""
        var nickname = ""
        var isEmailChecked = false
        var isEmailDuplicate = false

        var emailError: String?
        var passwordError: String?
        var passwordConfirmError: String?
        var nicknameError: String?

        var isCheckingEmail = false
        var isSigningUp = false

        var isSignUpEnabled: Bool {
            !email.isEmpty &&
            !password.isEmpty &&
            !passwordConfirm.isEmpty &&
            !nickname.isEmpty &&
            emailError == nil &&
            passwordError == nil &&
            passwordConfirmError == nil &&
            nicknameError == nil &&
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

        var nicknameValidationMessage: String? {
            nicknameError
        }

        var isEmailError: Bool {
            emailError != nil || isEmailDuplicate
        }

        @Presents var alert: AlertState<SignUpFeature.Alert>?
    }

    // MARK: - Action
    enum Action {
        case emailChanged(String)
        case passwordChanged(String)
        case passwordConfirmChanged(String)
        case nicknameChanged(String)
        case checkEmailButtonTapped
        case emailCheckCompleted(Bool)
        case emailCheckFailed(Error)
        case signUpButtonTapped
        case signUpCompleted
        case signUpFailed(Error)
        case alert(PresentationAction<SignUpFeature.Alert>)
    }

    // MARK: - Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(email):
                if state.email != email {
                    state.isEmailChecked = false
                    state.isEmailDuplicate = false
                }
                state.email = email

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
                guard state.password != password else { return .none }

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
                guard state.passwordConfirm != passwordConfirm else { return .none }

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

            case let .nicknameChanged(nickname):
                guard state.nickname != nickname else { return .none }

                state.nickname = nickname

                // 닉네임 유효성 검증
                if nickname.isEmpty {
                    state.nicknameError = nil
                } else {
                    switch validationUseCase.validateNickname(nickname: nickname) {
                    case .success:
                        state.nicknameError = nil
                    case .failure(let error):
                        state.nicknameError = error.errorDescription
                    }
                }
                return .none

            case .checkEmailButtonTapped:
                let email = state.email
                state.isCheckingEmail = true

                // 이메일 중복 검증
                return .run { send in
                    do {
                        try await checkEmailDuplicationUseCase.execute(email: email)
                        await send(.emailCheckCompleted(true))
                    } catch {
                        await send(.emailCheckFailed(error))
                    }
                }

            case let .emailCheckCompleted(success):
                state.isEmailChecked = true
                state.isEmailDuplicate = !success
                state.isCheckingEmail = false
                return .none

            case .emailCheckFailed(let error):
                state.isCheckingEmail = false
                state.alert = AlertState {
                    TextState("이메일 중복 확인 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .signUpButtonTapped:
                let email = state.email
                let password = state.password
                let nickname = state.nickname
                state.isSigningUp = true

                return .run { send in
                    do {
                        let deviceToken = (try? await getDeviceTokenUseCase.execute()) ?? ""

                        let request = JoinRequest(
                            email: email,
                            password: password,
                            nickname: nickname,
                            phoneNumber: "",
                            deviceToken: deviceToken
                        )

                        let response = try await joinUseCase.execute(request: request)

                        try await saveTokensUseCase.execute(
                            accessToken: response.accessToken,
                            refreshToken: response.refreshToken
                        )

                        await send(.signUpCompleted)
                    } catch {
                        await send(.signUpFailed(error))
                    }
                }
            
            case .signUpCompleted:
                state.isSigningUp = false
                return .none

            case .signUpFailed(let error):
                state.isSigningUp = false
                state.alert = AlertState {
                    TextState("회원가입 실패")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    // MARK: - Dependencies
    @Dependency(\.signUpInputValidation) var validationUseCase
    @Dependency(\.checkEmailDuplication) var checkEmailDuplicationUseCase
    @Dependency(\.getDeviceToken) var getDeviceTokenUseCase
    @Dependency(\.join) var joinUseCase
    @Dependency(\.saveTokens) var saveTokensUseCase

    enum Alert: Sendable {}
}
