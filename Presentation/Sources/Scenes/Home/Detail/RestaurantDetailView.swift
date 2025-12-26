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

            ZStack {
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
                            VStack(spacing: AppPadding.xLarge.value) {
                                // 여기에 가게 정보가 들어갈 예정
                                Text("가게 정보 영역")
                                    .padding(.top, .xLarge)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 20,
                                    topTrailingRadius: 20
                                )
                                .fill(.custom(.gray(.gray15)))
                            )
                            .offset(y: -20)
                        }
                    }
                    .ignoresSafeArea()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HeartButton(isLike: restaurant.isPick,
                                        nonLikeColor: .custom(.gray(.gray100))
                            ) {
                                store.send(.toggleRestaurantLike)
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
