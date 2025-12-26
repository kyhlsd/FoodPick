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
                            VStack(spacing: 0) {
                                // 가게 영역
                                VStack(spacing: AppPadding.xLarge.value) {
                                    RestaurantInfoSection(restaurant: restaurant)
                                        .padding([.top, .horizontal], .xLarge)

                                    VStack(spacing: AppPadding.medium.value) {
                                        RestaurantDetailsCard(restaurant: restaurant)

                                        EstimatedPickupTimeView(minutes: restaurant.estimatedPickupTime)

                                        PrimaryButton(title: "길찾기",
                                                      height: 44
                                        ) {

                                        }
                                    }
                                    .padding(.horizontal, .xLarge)
                                    
                                    MyDivider()
                                }
                                .frame(maxWidth: .infinity)
                                .background(.custom(.gray(.gray15)))

                                // 메뉴 영역
                                VStack(spacing: AppPadding.xLarge.value) {
                                    // 메뉴, 리뷰 등 추가 콘텐츠 영역
                                    Text("추가 콘텐츠 영역")
                                        .padding(.top, .xLarge)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, .xLarge)
                                .background(.custom(.gray(.gray0)))
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

// MARK: - Restaurant Info Section
private struct RestaurantInfoSection: View {
    let restaurant: RestaurantDetail

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 첫 번째 줄: 가게명 + 픽슐랭
            HStack(spacing: AppPadding.large.value) {
                Text(restaurant.name)
                    .font(.pretendard(size: .title1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                if restaurant.isPicchelin {
                    PicchelinView()
                }

                Spacer()
            }

            // 두 번째 줄: 좋아요, 평점, 누적 주문
            HStack(spacing: AppPadding.large.value) {
                // 좋아요
                HStack(spacing: 2) {
                    AppIcon.likeFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text("\(restaurant.pickCount)개")
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }

                // 평점
                HStack(spacing: 2) {
                    AppIcon.starFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text(String(format: "%.1f", restaurant.totalRating))
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))

                    Text("(\(restaurant.totalReviewCount))")
                        .font(.pretendard(size: .body1, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))

                    Button {

                    } label: {
                        AppIcon.chevron
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.gray(.gray60)))
                            .rotationEffect(.degrees(180))
                    }
                }

                Spacer()

                // 누적 주문
                Text("총 누적 주문 \(restaurant.totalOrderCount)회")
                    .font(.pretendard(size: .body3, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray45)))
            }
        }
    }
}

// MARK: - Restaurant Details Card
private struct RestaurantDetailsCard: View {
    let restaurant: RestaurantDetail

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            // 가게 주소
            DetailRow(
                icon: AppIcon.distance,
                title: "가게 주소",
                content: restaurant.address
            )

            // 영업 시간
            DetailRow(
                icon: AppIcon.time,
                title: "영업 시간",
                content: "매일 \(TimeFormatter.toFullAMPMFormat(from: restaurant.open)) ~ " +
                         "\(TimeFormatter.toFullAMPMFormat(from: restaurant.close))"
            )

            // 주차 여부
            DetailRow(
                icon: AppIcon.parking,
                title: "주차 여부",
                content: restaurant.parkingGuide
            )
        }
        .padding(.vertical, .medium)
        .padding(.horizontal, .large)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.custom(.gray(.gray0)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.custom(.gray(.gray30)), lineWidth: 1)
        )
    }
}

// MARK: - Detail Row
private struct DetailRow: View {
    let icon: Image
    let title: String
    let content: String

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            Text(title)
                .font(.pretendard(size: .body2, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray60)))

            HStack(spacing: AppPadding.tiny.value) {
                icon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.custom(.brand(.blackSprout)))

                Text(content)
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
            }

            Spacer()
        }
    }
}

// MARK: - Estimated Pickup Time View
private struct EstimatedPickupTimeView: View {
    let minutes: Int

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                AppIcon.run
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text("예상 소요시간 \(minutes)분")
                    .font(.pretendard(size: .body3, weight: .medium))
            }
            .foregroundStyle(.custom(.brand(.deepSprout)))
            .padding(.horizontal, AppPadding.small.value)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.custom(.gray(.gray0)))
            )
            .overlay(
                Capsule()
                    .stroke(.custom(.gray(.gray30)), lineWidth: 1)
            )
            
            Spacer()
        }
    }
}
