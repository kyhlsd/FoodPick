//
//  InputFieldView.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI

struct InputFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.small.value) {
            Text(title)
                .font(.pretendard(size: .body2, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray75)))

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.pretendard(size: .body1, weight: .bold))
                    .padding(.all, .medium)
                    .background(Color.custom(.gray(.gray0)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.custom(.gray(.gray30)), lineWidth: 1)
                    )
                    .textContentType(.none)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder, text: $text)
                    .font(.pretendard(size: .body1, weight: .bold))
                    .padding(.all, .medium)
                    .background(Color.custom(.gray(.gray0)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.custom(.gray(.gray30)), lineWidth: 1)
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .textContentType(.none)
            }
        }
    }
}

struct InputFieldWithMessageView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var message: String?
    var isError: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            InputFieldView(
                title: title,
                placeholder: placeholder,
                text: $text,
                isSecure: isSecure,
                keyboardType: keyboardType
            )

            Group {
                if let message = message {
                    Text(message)
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(isError ? .red : .green)
                } else {
                    Text(" ")
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 16)
            .padding([.top, .leading], 2)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InputFieldView(
            title: "이메일",
            placeholder: "이메일을 입력하세요",
            text: .constant(""),
            isSecure: false,
            keyboardType: .emailAddress
        )

        InputFieldView(
            title: "비밀번호",
            placeholder: "비밀번호를 입력하세요",
            text: .constant(""),
            isSecure: true
        )

        InputFieldWithMessageView(
            title: "비밀번호 확인",
            placeholder: "비밀번호를 다시 입력하세요",
            text: .constant("12345"),
            isSecure: true,
            message: "비밀번호가 일치하지 않습니다",
            isError: true
        )

        InputFieldWithMessageView(
            title: "이메일",
            placeholder: "이메일을 입력하세요",
            text: .constant("test@example.com"),
            keyboardType: .emailAddress,
            message: "사용 가능한 이메일입니다",
            isError: false
        )

        InputFieldWithMessageView(
            title: "닉네임",
            placeholder: "닉네임을 입력하세요",
            text: .constant(""),
            message: nil,
            isError: false
        )
    }
    .padding()
}
