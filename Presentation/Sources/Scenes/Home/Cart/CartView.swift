//
//  CartView.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct CartView: View {
    let store: StoreOf<CartFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let cartItems = store.cartItems
            let cartTotalPrice = store.cartTotalPrice
            let cartTotalCount = store.cartTotalCount

            ZStack(alignment: .bottom) {
                Color.custom(.gray(.gray0))
                    .ignoresSafeArea()

                if cartItems.isEmpty {
                    // 빈 장바구니
                    EmptyCartView()
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(Array(cartItems.enumerated()), id: \.element.menu.menuId) { index, item in
                                    CartItemRow(
                                        menu: item.menu,
                                        quantity: item.quantity,
                                        onIncrease: {
                                            store.send(.quantityIncreased(menuId: item.menu.menuId))
                                        },
                                        onDecrease: {
                                            store.send(.quantityDecreased(menuId: item.menu.menuId))
                                        },
                                        onDelete: {
                                            store.send(.removeFromCart(menuId: item.menu.menuId))
                                        }
                                    )
                                    .padding(.horizontal, .xLarge)
                                    .padding(.vertical, .medium)

                                    if index < cartItems.count - 1 {
                                        MyDivider()
                                            .padding(.horizontal, .xLarge)
                                    }
                                }
                            }
                            .padding(.bottom, 120)
                        }

                        Spacer()
                    }

                    // 하단 결제 영역
                    VStack(spacing: 0) {
                        MyDivider()

                        VStack(spacing: AppPadding.medium.value) {
                            // 총 금액 표시
                            HStack {
                                Text("총 \(cartTotalCount)개")
                                    .font(.pretendard(size: .body1, weight: .medium))
                                    .foregroundStyle(.custom(.gray(.gray60)))

                                Spacer()

                                Text("\(cartTotalPrice.formatted())원")
                                    .font(.pretendard(size: .title1, weight: .bold))
                                    .foregroundStyle(.custom(.gray(.gray90)))
                            }

                            // 결제하기 버튼
                            PrimaryButton(
                                title: "결제하기",
                                height: 48
                            ) {
                                store.send(.checkoutTapped)
                            }
                        }
                        .padding(.horizontal, .xLarge)
                        .padding(.vertical, .medium)
                        .background(.custom(.gray(.gray0)))
                    }
                    .shadow(color: .custom(.gray(.gray75)).opacity(0.1), radius: 12)
                }
            }
            .navigationTitle("장바구니")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.payment, action: \.destination.payment)
            ) { store in
                PaymentView(store: store)
            }
        }
    }
}

// MARK: - Empty Cart View
private struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: AppPadding.large.value) {
            Spacer()

            AppIcon.cart
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.custom(.gray(.gray45)))

            Text("장바구니가 비어있습니다")
                .font(.pretendard(size: .body1, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray60)))

            Spacer()
        }
    }
}

// MARK: - Cart Item Row
private struct CartItemRow: View {
    let menu: Domain.Menu
    let quantity: Int
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            // 메뉴 이미지
            AuthenticatedImage(imagePath: menu.menuImageURL)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // 메뉴 정보 및 수량 조절
            VStack(alignment: .leading, spacing: AppPadding.small.value) {
                // 메뉴 이름
                Text(menu.name)
                    .font(.pretendard(size: .body1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                // 가격
                Text("\(menu.price.formatted())원")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))

                // 수량 조절 + 휴지통
                HStack(spacing: AppPadding.small.value) {
                    Button {
                        onDecrease()
                    } label: {
                        AppIcon.minusSquare
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                    .buttonStyle(.plain)

                    Text("\(quantity)")
                        .font(.pretendard(size: .body2, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                        .frame(minWidth: 20)

                    Button {
                        onIncrease()
                    } label: {
                        AppIcon.plusSquare
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                    .buttonStyle(.plain)

                    // 휴지통 버튼
                    Button {
                        onDelete()
                    } label: {
                        AppIcon.trash
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            // 총 가격 (메뉴 가격 × 수량)
            Text("\((menu.price * quantity).formatted())원")
                .font(.pretendard(size: .body1, weight: .bold))
                .foregroundStyle(.custom(.gray(.gray90)))
        }
    }
}

// MARK: - Preview
#Preview("장바구니 - 아이템 있음") {
    NavigationStack {
        CartView(
            store: Store(
                initialState: CartFeature.State(
                    cartItems: [
                        (
                            menu: Menu(
                                menuId: "1",
                                restaurantId: "1",
                                category: "커피",
                                name: "아메리카노",
                                description: "진한 에스프레소",
                                originInfo: "브라질",
                                price: 4500,
                                isSoldOut: false,
                                tags: [],
                                menuImageURL: "",
                                createdAt: Date(),
                                updatedAt: Date()
                            ),
                            quantity: 2
                        ),
                        (
                            menu: Menu(
                                menuId: "2",
                                restaurantId: "1",
                                category: "디저트",
                                name: "케이크",
                                description: "달콤한 케이크",
                                originInfo: "한국",
                                price: 6000,
                                isSoldOut: false,
                                tags: [],
                                menuImageURL: "",
                                createdAt: Date(),
                                updatedAt: Date()
                            ),
                            quantity: 1
                        )
                    ]
                )
            ) {
                CartFeature()
            }
        )
    }
}

#Preview("장바구니 - 비어있음") {
    NavigationStack {
        CartView(
            store: Store(
                initialState: CartFeature.State(
                    cartItems: []
                )
            ) {
                CartFeature()
            }
        )
    }
}
