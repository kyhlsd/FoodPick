//
//  RestaurantInfoViews.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import SwiftUI
import Domain

// MARK: - Restaurant Info Section
struct RestaurantInfoSection: View {
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
struct RestaurantDetailsCard: View {
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
        HStack(alignment: .top, spacing: AppPadding.medium.value) {
            Text(title)
                .font(.pretendard(size: .body2, weight: .medium))
                .foregroundStyle(.custom(.gray(.gray60)))

            HStack(alignment: .top, spacing: AppPadding.tiny.value) {
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
struct EstimatedPickupTimeView: View {
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
