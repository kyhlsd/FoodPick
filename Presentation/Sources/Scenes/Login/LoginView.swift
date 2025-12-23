//
//  LoginView.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            ScrollView {
                VStack(spacing: AppPadding.xLarge.value) {
                    // 타이틀
                    TitleView()
                    
                    Spacer()
                        .frame(height: AppPadding.xLarge.value)
                    
                    // 이메일 입력
                    InputFieldView(
                        title: "이메일",
                        placeholder: "이메일을 입력하세요",
                        text: $store.email.sending(\.emailChanged),
                        isSecure: false,
                        keyboardType: .emailAddress
                    )
                    
                    // 비밀번호 입력
                    InputFieldView(
                        title: "비밀번호",
                        placeholder: "비밀번호를 입력하세요",
                        text: $store.password.sending(\.passwordChanged),
                        isSecure: true
                    )
                    
                    // 로그인 버튼
                    PrimaryButton(
                        title: "로그인",
                        isEnabled: store.isLoginEnabled,
                        isLoading: store.isLoggingIn
                    ) {
                        store.send(.loginButtonTapped)
                    }
                    
                    // 구분선
                    HStack {
                        MyDivider()
                        
                        Text("또는")
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                            .padding(.horizontal, .small)
                        
                        MyDivider()
                    }
                    .padding(.bottom, .medium)
                    
                    // 소셜 로그인 버튼
                    HStack(spacing: AppPadding.xLarge.value) {
                        KakaoLoginButton(isLoading: store.isLoggingIn) {
                            store.send(.kakaoLoginButtonTapped)
                        }
                        AppleLoginButton(isLoading: store.isLoggingIn) {
                            store.send(.appleLoginButtonTapped)
                        }
                    }
                    
                    // 회원 가입 버튼
                    SignUpButton {
                        store.send(.joinButtonTapped)
                    }
                    
                    Spacer()
                }
                .padding([.horizontal, .top], .xLarge)
            }
            .scrollIndicators(.hidden)
            .hideKeyboardOnTap()
            .navigationDestination(
                item: $store.scope(state: \.destination?.signUp, action: \.destination.signUp)
            ) { signUpStore in
                SignUpView(store: signUpStore)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

private struct TitleView: View {
    var body: some View {
        Text("FoodPick")
            .font(.jalnan(.title1))
            .foregroundStyle(.custom(.brand(.blackSprout)))
    }
}

private struct KakaoLoginButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: "#FEE500"))
                .frame(width: 60, height: 60)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.black)
                        } else {
                            AppIcon.kakao
                                .resizable()
                                .font(.pretendard(size: .title1, weight: .bold))
                        }
                    }
                )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

private struct AppleLoginButton: View {
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.custom(.gray(.gray100)))
                .frame(width: 60, height: 60)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 24))
                                .foregroundStyle(.custom(.gray(.gray0)))
                        }
                    }
                )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
}

private struct SignUpButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppPadding.tiny.value) {
                Text("아직 회원이 아니신가요?")
                    .font(.pretendard(size: .caption1, weight: .semiBold))
                    .foregroundStyle(.custom(.gray(.gray60)))

                Text("회원가입")
                    .font(.pretendard(size: .caption1, weight: .semiBold))
                    .foregroundStyle(.custom(.brand(.blackSprout)))
                    .underline()
            }
        }
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State()) {
            LoginFeature()
        }
    )
}
