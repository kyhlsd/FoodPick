//
//  SignUpView.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    let store: StoreOf<SignUpFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ScrollView {
                VStack(spacing: AppPadding.medium.value) {
                    // 이메일 입력 및 중복 체크
                    VStack(alignment: .leading, spacing: AppPadding.small.value) {
                        HStack(spacing: AppPadding.small.value) {
                            InputFieldWithMessageView(
                                title: "이메일",
                                placeholder: "이메일을 입력하세요",
                                text: $store.email.sending(\.emailChanged),
                                keyboardType: .emailAddress,
                                message: store.emailValidationMessage,
                                isError: store.isEmailError
                            )

                            VStack {
                                Spacer()
                                    .frame(height: 4)
                                
                                PrimaryButton(title: "중복 확인",
                                              height: 46,
                                              isEnabled: store.isEmailCheckEnabled,
                                              isLoading: store.isCheckingEmail
                                ) {
                                    store.send(.checkEmailButtonTapped)
                                }
                                .frame(width: 100)
                            }
                        }
                    }

                    // 닉네임 입력
                    InputFieldWithMessageView(
                        title: "닉네임",
                        placeholder: "닉네임을 입력하세요",
                        text: $store.nickname.sending(\.nicknameChanged),
                        message: store.nicknameValidationMessage,
                        isError: store.nicknameValidationMessage != nil
                    )

                    // 비밀번호 입력
                    InputFieldWithMessageView(
                        title: "비밀번호",
                        placeholder: "비밀번호를 입력하세요",
                        text: $store.password.sending(\.passwordChanged),
                        isSecure: true,
                        message: store.passwordValidationMessage,
                        isError: store.passwordValidationMessage != nil
                    )

                    // 비밀번호 확인
                    InputFieldWithMessageView(
                        title: "비밀번호 확인",
                        placeholder: "비밀번호를 다시 입력하세요",
                        text: $store.passwordConfirm.sending(\.passwordConfirmChanged),
                        isSecure: true,
                        message: store.passwordConfirmMessage,
                        isError: store.passwordConfirmMessage != nil
                    )

                    // 회원가입 버튼
                    PrimaryButton(
                        title: "회원가입",
                        isEnabled: store.isSignUpEnabled,
                        isLoading: store.isSigningUp
                    ) {
                        store.send(.signUpButtonTapped)
                    }

                    Spacer()
                }
                .padding([.horizontal, .top], .xLarge)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .hideKeyboardOnTap()
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView(
            store: Store(initialState: SignUpFeature.State()) {
                SignUpFeature()
            }
        )
    }
}
