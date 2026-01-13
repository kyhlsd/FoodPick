//
//  RestaurantDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 12/26/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct RestaurantDetailView: View {
    let store: StoreOf<RestaurantDetailFeature>
    
    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let isLoading = store.isLoading
            let restaurantInfo = store.restaurantInfo
            let currentImageIndex = store.currentImageIndex

            ZStack(alignment: .bottom) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .custom(.brand(.blackSprout))))
                } else if let restaurant = restaurantInfo {
                    ScrollView {
                        VStack(spacing: 0) {
                            // 이미지 영역
                            ZStack(alignment: .bottom) {
                                TabView(selection: $store.currentImageIndex.sending(\.imageIndexChanged)) {
                                    ForEach(Array(restaurant.restaurantImageURLs.enumerated()),
                                            id: \.offset) { index, imagePath in
                                        AuthenticatedImage(imagePath: imagePath)
                                            .frame(height: 240)
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 240)
                                
                                // Page Control
                                if restaurant.restaurantImageURLs.count > 1 {
                                    HStack(spacing: AppPadding.small.value) {
                                        ForEach(0..<restaurant.restaurantImageURLs.count, id: \.self) { index in
                                            if currentImageIndex == index {
                                                Circle()
                                                    .fill(.custom(.gray(.gray0)))
                                                    .frame(width: 8, height: 8)
                                            } else {
                                                Circle()
                                                    .fill(.custom(.gray(.gray45)))
                                                    .frame(width: 4, height: 4)
                                            }
                                            
                                        }
                                    }
                                    .padding(.bottom, AppPadding.medium.value + 20)
                                }
                            }
                            
                            // 컨텐츠 영역
                            VStack(spacing: 0) {
                                // 가게 영역
                                VStack(spacing: AppPadding.xLarge.value) {
                                    RestaurantInfoSection(
                                        restaurant: restaurant
                                    ) {
                                        store.send(.reviewTapped)
                                    }
                                    .padding([.top, .horizontal], .xLarge)
                                    
                                    VStack(spacing: AppPadding.medium.value) {
                                        RestaurantDetailsCard(restaurant: restaurant)
                                        
                                        EstimatedPickupTimeView(minutes: restaurant.estimatedPickupTime)
                                        
                                        PrimaryButton(title: "길찾기",
                                                      height: 44
                                        ) {
                                            store.send(.directionTapped)
                                        }
                                    }
                                    .padding(.horizontal, .xLarge)
                                    
                                    MyDivider()
                                }
                                .frame(maxWidth: .infinity)
                                .background(.custom(.gray(.gray15)))
                                
                                // 메뉴 영역
                                MenuSectionView(
                                    store: store.scope(
                                        state: \.menuSection,
                                        action: \.menuSection
                                    )
                                )
                            }
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 20,
                                    topTrailingRadius: 20
                                )
                            )
                            .offset(y: -20)
                        }
                    }
                    .ignoresSafeArea(edges: .top)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HeartButton(isLike: restaurant.isPick,
                                        nonLikeColor: .custom(.gray(.gray100))
                            ) {
                                store.send(.toggleRestaurantLike)
                            }
                        }
                    }

                    // 하단 결제 영역 (검색바 포커스 시 숨김)
                    if !store.menuSection.isSearchBarFocused {
                        CartSectionView(
                            store: store.scope(
                                state: \.cartSection,
                                action: \.cartSection
                            )
                        )
                    }
                }
            }
            .hideKeyboardOnTap()
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.menuDetail, action: \.destination.menuDetail)
            ) { store in
                MenuDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.cart, action: \.destination.cart)
            ) { store in
                CartView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.review, action: \.destination.review)
            ) { store in
                ReviewView(store: store)
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.direction, action: \.destination.direction)
            ) { directionStore in
                DirectionView(store: directionStore)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        RestaurantDetailView(
            store: Store(
                initialState: RestaurantDetailFeature.State(
                    restaurantId: "1",
                    cartSection: CartSectionFeature.State(
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
                )
            ) {
                RestaurantDetailFeature()
            }
        )
    }
}
