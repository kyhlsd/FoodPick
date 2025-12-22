//
//  MySearchBar.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import SwiftUI

struct MySearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void

    init(
        text: Binding<String>,
        placeholder: String = "검색어를 입력해주세요",
        onSubmit: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            AppIcon.search
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(.custom(.brand(.blackSprout)))

            TextField(placeholder, text: $text)
                .font(.custom(.pretendard(.body2)))
                .foregroundStyle(.custom(.gray(.gray90)))
                .submitLabel(.search)
                .onSubmit {
                    onSubmit()
                }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    AppIcon.xmarkCircle
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.custom(.gray(.gray45)))
                }
            }
        }
        .padding(.vertical, .medium)
        .padding(.horizontal, .large)
        .background(
            Capsule()
                .fill(Color.custom(.gray(.gray0)))
        )
        .overlay(
            Capsule()
                .stroke(.custom(.brand(.deepSprout)), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        MySearchBar(
            text: .constant("")
        ) {
            
        }

        MySearchBar(
            text: .constant(""),
            placeholder: "커스텀 플레이스홀더"
        ) {

        }
    }
    .padding()
}
