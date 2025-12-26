//
//  RestaurantDetailItemView.swift
//  Presentation
//
//  Created by 김영훈 on 12/24/25.
//

import SwiftUI
import Domain

struct RestaurantDetailItemView: View {
    let restaurant: Restaurant
    let onLikeToggle: (String, Bool) -> Void
    let onRestaurantTap: (String) -> Void

    var body: some View {
        VStack(spacing: AppPadding.large.value) {
            Button {
                onRestaurantTap(restaurant.restaurantId)
            } label: {
                VStack(spacing: AppPadding.large.value) {
                    // 이미지 영역
                    HStack(spacing: AppPadding.tiny.value) {
                        // 첫번째 사진
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.custom(.gray(.gray30)))
                                .overlay {
                                    AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

                            // 픽슐랭, 하트
                            HStack(alignment: .top) {
                                HeartButton(isLike: restaurant.isPick) {
                                    onLikeToggle(restaurant.restaurantId, !restaurant.isPick)
                                }

                                Spacer()

                                if restaurant.isPicchelin {
                                    PicchelinView()
                                }
                            }
                            .padding(.horizontal, AppPadding.small.value)
                            .padding(.top, AppPadding.small.value)
                        }
                        .frame(maxWidth: .infinity)

                        // 두번째, 세번째 사진
                        VStack(spacing: AppPadding.tiny.value) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.custom(.gray(.gray30)))
                                .overlay {
                                    AuthenticatedImage(imagePath:
                                                        restaurant.restaurantImageURLs.count > 1
                                                       ? restaurant.restaurantImageURLs[1]
                                                       : nil
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }

                            // 세번째 사진
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.custom(.gray(.gray30)))
                                .overlay {
                                    AuthenticatedImage(imagePath:
                                                        restaurant.restaurantImageURLs.count > 2
                                                       ? restaurant.restaurantImageURLs[2]
                                                       : nil
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                        }
                        .frame(width: 78)
                    }
                    .frame(height: 127)

                    // 가게 정보
                    RestaurantInfoView(restaurant: restaurant)
                }
            }
            .buttonStyle(.plain)

            MyDivider()
        }
    }
}

// MARK: - Restaurant Info View
private struct RestaurantInfoView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(spacing: AppPadding.small.value) {
            // 첫번째 줄: 가게명, 좋아요, 별점
            HStack(spacing: AppPadding.medium.value) {
                Text(restaurant.name)
                    .font(.pretendard(size: .body1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                HStack(spacing: 2) {
                    AppIcon.likeFill
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text("\(restaurant.pickCount)개")
                        .font(.pretendard(size: .body1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }

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
                }

                Spacer()
            }

            // 두번째 줄: 거리, 시간, 주문횟수
            HStack(spacing: AppPadding.large.value) {
                InfoItemView(
                    icon: AppIcon.distance,
                    text: DistanceFormatter.format(restaurant.distance)
                )
                InfoItemView(
                    icon: AppIcon.time,
                    text: TimeFormatter.toAMPMFormat(from: restaurant.close)
                )
                InfoItemView(
                    icon: AppIcon.run,
                    text: "\(restaurant.totalOrderCount)회"
                )
                Spacer()
            }

            // 세번째 줄: 해시태그
            HStack(spacing: AppPadding.small.value) {
                ForEach(restaurant.hashTags, id: \.self) { tag in
                    Text(tag)
                        .font(.pretendard(size: .caption1, weight: .semiBold))
                        .foregroundStyle(.custom(.gray(.gray0)))
                        .padding(.horizontal, AppPadding.small.value)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.custom(.brand(.deepSprout)))
                        )
                }
                Spacer()
            }
        }
    }
}

// MARK: - Info Item View
private struct InfoItemView: View {
    let icon: Image
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            icon
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundStyle(.custom(.brand(.blackSprout)))

            Text(text)
                .font(.pretendard(size: .body2, weight: .regular))
                .foregroundStyle(.custom(.gray(.gray60)))
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(white: 0.95).edgesIgnoringSafeArea(.all)
        RestaurantDetailItemView(
            restaurant: Restaurant(
                restaurantId: "1",
                category: .cafe,
                name: "스타벅스 강남점",
                close: "22:00",
                restaurantImageURLs: [
                    "restaurants/starbucks1.jpg",
                    "restaurants/starbucks2.jpg"
                ],
                isPicchelin: true,
                isPick: true,
                pickCount: 120,
                hashTags: ["커피", "디저트", "조용한"],
                totalRating: 4.5,
                totalOrderCount: 1500,
                totalReviewCount: 300,
                geolocation: Geolocation(longitude: 127.0, latitude: 37.5),
                distance: 0.5,
                createdAt: Date(),
                updatedAt: Date()
            )
        ) { _, _ in

        } onRestaurantTap: { _ in

        }
        .padding()
    }
}
