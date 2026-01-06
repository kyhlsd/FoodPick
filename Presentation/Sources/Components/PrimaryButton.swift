//
//  PrimaryButton.swift
//  Presentation
//
//  Created by 김영훈 on 12/18/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let height: CGFloat
    let fontSize: AppFont.Pretendard
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        height: CGFloat = 50,
        fontSize: AppFont.Pretendard = .title1,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.height = height
        self.fontSize = fontSize
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.pretendard(size: fontSize, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray0)))
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.gray(.gray0))))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(isEnabled && !isLoading ?
                        Color.custom(.brand(.blackSprout))
                        : Color.custom(.brand(.deepSprout)))
            .cornerRadius(10)
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "로그인", isEnabled: true, isLoading: false) {}

        PrimaryButton(title: "로그인", isEnabled: false, isLoading: false) {}

        PrimaryButton(title: "로그인", isEnabled: true, isLoading: true) {}
    }
    .padding()
}
