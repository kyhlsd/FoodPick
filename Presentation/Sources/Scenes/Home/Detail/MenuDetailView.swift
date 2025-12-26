//
//  MenuDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct MenuDetailView: View {
    let store: StoreOf<MenuDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            let menu = store.menu
            let quantity = store.quantity
            let totalPrice = store.totalPrice

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 메뉴 이미지
                    AuthenticatedImage(imagePath: menu.menuImageURL)
                        .frame(height: 240)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: AppPadding.large.value) {
                        // 메뉴 이름
                        Text(menu.name)
                            .font(.pretendard(size: .title1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))

                        // 설명
                        Text(menu.description)
                            .font(.pretendard(size: .body2, weight: .regular))
                            .foregroundStyle(.custom(.gray(.gray60)))
                            .lineSpacing(4)

                        // 원산지 정보
                        Text(menu.originInfo)
                            .font(.pretendard(size: .body3, weight: .regular))
                            .foregroundStyle(.custom(.gray(.gray45)))
                            .lineSpacing(4)

                        MyDivider()

                        // 가격
                        Text("\(menu.price.formatted())원")
                            .font(.pretendard(size: .title1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))

                        MyDivider()

                        // 수량 조절
                        HStack {
                            Text("수량")
                                .font(.pretendard(size: .body1, weight: .bold))
                                .foregroundStyle(.custom(.gray(.gray90)))

                            Spacer()

                            HStack(spacing: AppPadding.small.value) {
                                Button {
                                    store.send(.quantityDecreased)
                                } label: {
                                    AppIcon.minusSquare
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(.custom(.gray(.gray60)))
                                }
                                .buttonStyle(.plain)

                                Text("\(quantity)")
                                    .font(.pretendard(size: .body1, weight: .bold))
                                    .foregroundStyle(.custom(.gray(.gray90)))
                                    .frame(minWidth: 24)

                                Button {
                                    store.send(.quantityIncreased)
                                } label: {
                                    AppIcon.plusSquare
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(.custom(.gray(.gray60)))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        MyDivider()

                        // 총 금액
                        HStack {
                            Text("총 금액")
                                .font(.pretendard(size: .body1, weight: .bold))
                                .foregroundStyle(.custom(.gray(.gray90)))

                            Spacer()

                            Text("\(totalPrice.formatted())원")
                                .font(.pretendard(size: .title1, weight: .bold))
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                        }
                    }
                    .padding(.horizontal, .xLarge)
                    .padding(.top, .xLarge)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MenuDetailView(
            store: Store(
                initialState: MenuDetailFeature.State(
                    menu: Menu(
                        menuId: "1",
                        restaurantId: "1",
                        category: "커피",
                        name: "아메리카노",
                        description: "진한 에스프레소에 물을 더해 깔끔하게 즐기는 커피",
                        originInfo: "원두: 브라질, 콜롬비아",
                        price: 4500,
                        isSoldOut: false,
                        tags: ["인기", "시그니처"],
                        menuImageURL: "menus/americano.jpg",
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                )
            ) {
                MenuDetailFeature()
            }
        )
    }
}
