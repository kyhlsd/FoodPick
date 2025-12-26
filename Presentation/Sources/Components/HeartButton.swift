//
//  HeartButton.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import SwiftUI

struct HeartButton: View {
    var isLike: Bool
    let nonLikeColor: Color
    let action: () -> Void
    
    init(isLike: Bool,
         nonLikeColor: Color = .custom(.gray(.gray45)),
         action: @escaping () -> Void
    ) {
        self.isLike = isLike
        self.nonLikeColor = nonLikeColor
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            if isLike {
                AppIcon.likeFill
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.custom(.brand(.blackSprout)))
            } else {
                AppIcon.likeEmpty
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(nonLikeColor)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        HeartButton(isLike: true) {
            
        }
        HeartButton(isLike: false) {
            
        }
    }
}
