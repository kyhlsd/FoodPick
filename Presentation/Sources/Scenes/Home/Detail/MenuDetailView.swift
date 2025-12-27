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
            let isInCart = store.isInCart

            ZStack(alignment: .bottom) {
                Color.custom(.gray(.gray0))
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 메뉴 이미지
                        AuthenticatedImage(imagePath: menu.menuImageURL)
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)

                        // 컨텐츠 영역
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
                        .padding([.horizontal, .top], .xLarge)
                        .padding(.top, .xLarge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color.custom(.gray(.gray0))
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 20,
                                        topTrailingRadius: 20
                                    )
                                )
                        )
                        .offset(y: -20)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // 하단 고정 버튼
                PrimaryButton(
                    title: {
                        if menu.isSoldOut {
                            return "품절된 메뉴입니다"
                        } else if isInCart {
                            return quantity == 0 ? "장바구니에서 삭제" : "장바구니 수정하기"
                        } else {
                            return "장바구니 담기"
                        }
                    }(),
                    height: 44,
                    isEnabled: !menu.isSoldOut
                ) {
                    store.send(.addToCartTapped)
                }
                .padding(.horizontal, .xLarge)
                .padding(.top, .medium)
                .shadow(color: .custom(.gray(.gray75)).opacity(0.1), radius: 12)
            }
            .padding(.bottom, .medium)
            .background(.custom(.gray(.gray0)))
        }
    }
}

// MARK: - Preview
#Preview("일반 메뉴") {
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

#Preview("품절 메뉴") {
    NavigationStack {
        MenuDetailView(
            store: Store(
                initialState: MenuDetailFeature.State(
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
            ) {
                MenuDetailFeature()
            }
        )
    }
}

#Preview("장바구니에 담긴 메뉴") {
    NavigationStack {
        MenuDetailView(
            store: Store(
                initialState: MenuDetailFeature.State(
                    menu: Menu(
                        menuId: "3",
                        restaurantId: "1",
                        category: "음료",
                        name: "카페라떼",
                        description: "부드러운 우유와 진한 에스프레소의 조화",
                        originInfo: "원두: 에티오피아",
                        price: 5000,
                        isSoldOut: false,
                        tags: ["인기"],
                        menuImageURL: "menus/latte.jpg",
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    quantity: 3,
                    isInCart: true
                )
            ) {
                MenuDetailFeature()
            }
        )
    }
}

#Preview("장바구니에서 삭제 (수량 0)") {
    NavigationStack {
        MenuDetailView(
            store: Store(
                initialState: MenuDetailFeature.State(
                    menu: Menu(
                        menuId: "4",
                        restaurantId: "1",
                        category: "음료",
                        name: "아이스티",
                        description: "시원하고 상쾌한 아이스티",
                        originInfo: "홍차: 스리랑카",
                        price: 4000,
                        isSoldOut: false,
                        tags: [],
                        menuImageURL: "menus/icetea.jpg",
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    quantity: 0,
                    isInCart: true
                )
            ) {
                MenuDetailFeature()
            }
        )
    }
}
