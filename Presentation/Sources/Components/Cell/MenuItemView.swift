//
//  MenuItemView.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import SwiftUI
import Domain

struct MenuItemView: View {
    let menu: Domain.Menu
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.small.value) {
            // 태그
            if !menu.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppPadding.tiny.value) {
                        ForEach(menu.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.pretendard(size: .caption2, weight: .semiBold))
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                                .padding(.horizontal, AppPadding.small.value)
                                .padding(.vertical, AppPadding.tiny.value)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.custom(.brand(.brightSprout)))
                                )
                        }
                    }
                }
            }
            
            
            HStack(alignment: .top, spacing: AppPadding.medium.value) {
                // 왼쪽: 메뉴 이름, 설명, 가격
                VStack(alignment: .leading) {
                    // 메뉴 이름
                    Text(menu.name)
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                    
                    Spacer()
                    
                    // 설명
                    Text(menu.description)
                        .font(.pretendard(size: .caption1, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))
                        .lineLimit(2)
                        .lineSpacing(4)
                    
                    Spacer()
                    
                    // 가격
                    Text("\(menu.price.formatted())원")
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }
                
                Spacer(minLength: AppPadding.medium.value)
                
                // 오른쪽: 이미지
                AuthenticatedImage(imagePath: menu.menuImageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
