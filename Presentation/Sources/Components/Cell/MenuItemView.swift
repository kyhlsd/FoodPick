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
                VStack(alignment: .leading, spacing: AppPadding.small.value) {
                    // 메뉴 이름
                    Text(menu.name)
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

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
                .frame(maxWidth: .infinity, alignment: .leading)

                // 오른쪽: 이미지
                ZStack {
                    AuthenticatedImage(imagePath: menu.menuImageURL)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    if menu.isSoldOut {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#2D3031").opacity(0.6))
                            .frame(width: 100, height: 100)

                        Text("품절")
                            .font(.pretendard(size: .body1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray0)))
                    }
                }
                .frame(width: 100, height: 100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MenuItemView(
            menu: Menu(
                menuId: "1",
                restaurantId: "1",
                category: "커피",
                name: "아메리카노",
                description: "진한 에스프레소에 물을 더해 깔끔하게 즐기는 커피",
                originInfo: "원두: 브라질, 콜롬비아",
                price: 4500,
                isSoldOut: false,
                tags: ["인기", "시그니처", "HOT"],
                menuImageURL: "menus/americano.jpg",
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        .padding(.horizontal, .xLarge)

        MyDivider()
            .padding(.horizontal, .xLarge)

        MenuItemView(
            menu: Menu(
                menuId: "2",
                restaurantId: "1",
                category: "디저트",
                name: "치즈케이크",
                description: "부드럽고 진한 크림치즈와 바삭한 쿠키 베이스가 조화를 이루는 달콤한 디저트",
                originInfo: "크림치즈: 뉴질랜드",
                price: 6500,
                isSoldOut: true,
                tags: ["베스트"],
                menuImageURL: "menus/cheesecake.jpg",
                createdAt: Date(),
                updatedAt: Date()
            )
        )
        .padding(.horizontal, .xLarge)
    }
    .background(Color.custom(.gray(.gray0)))
}
