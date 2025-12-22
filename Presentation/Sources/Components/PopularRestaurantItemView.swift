//
//  PopularRestaurantItemView.swift
//  Presentation
//
//  Created by 김영훈 on 12/22/25.
//

import SwiftUI
import Domain

struct PopularRestaurantItemView: View {
    let restaurant: Restaurant
    let onLikeToggle: (String, Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // 배경
                RoundedStepShape()
                    .fill(.custom(.gray(.gray30)))
                    .frame(height: 120)
                    // .overlay(
                    //     Image("your_image_name")
                    //         .resizable()
                    //         .scaledToFill()
                    //         .clipShape(CustomTopBackgroundShape())
                    // )
                
                // 상단 Overlay Items
                HStack(alignment: .top) {
                    HeartButton(isLike: restaurant.isPick) {
                        onLikeToggle(restaurant.restaurantId, !restaurant.isPick)
                    }

                    Spacer()
                }
                .padding(.horizontal, AppPadding.small.value)
                .padding(.top, AppPadding.small.value)
            }

            // 가게 정보
            RestaurantInfoView(restaurant: restaurant)
                .frame(height: 56)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .custom(.gray(.gray75)).opacity(0.08),
                radius: 12,
                x: 0,
                y: 4
        )
        .frame(width: 240)
    }
}

// MARK: - Rounded Step Shape
private struct RoundedStepShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let mainCorner: CGFloat = 20
        let cutRadius: CGFloat = 12
        let cutWidth: CGFloat = 40
        let cutHeight: CGFloat = 40
        
        // 1. 우측 하단에서 시작
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // 2. 좌측 하단까지 (직선)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // 3. 위로 올라가다가 첫 번째 꺾임 (좌측 벽 -> 오른쪽으로)
        path.addLine(to: CGPoint(x: rect.minX, y: cutHeight + cutRadius))
        path.addArc(center: CGPoint(x: rect.minX + cutRadius, y: cutHeight + cutRadius),
                    radius: cutRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // 4. 오른쪽으로 가다가 두 번째 꺾임 (수평선 -> 위쪽으로)
        path.addLine(to: CGPoint(x: cutWidth - cutRadius, y: cutHeight))
        path.addArc(center: CGPoint(x: cutWidth - cutRadius, y: cutHeight - cutRadius),
                    radius: cutRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 0),
                    clockwise: true) // 안쪽으로 꺾일 때는 true
        
        // 5. 위로 올라가다가 세 번째 꺾임 (수직선 -> 다시 오른쪽 상단 벽으로)
        path.addLine(to: CGPoint(x: cutWidth, y: rect.minY + cutRadius))
        path.addArc(center: CGPoint(x: cutWidth + cutRadius, y: rect.minY + cutRadius),
                    radius: cutRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        // 6. 상단 오른쪽 끝까지 이동
        path.addLine(to: CGPoint(x: rect.maxX - mainCorner, y: rect.minY))
        
        // 7. 우측 상단 모서리 둥글게
        path.addArc(center: CGPoint(x: rect.maxX - mainCorner, y: rect.minY + mainCorner),
                    radius: mainCorner,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Restaurant Info View
private struct RestaurantInfoView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: AppPadding.medium.value) {
                Text(restaurant.name)
                    .font(.custom(.pretendard(.body4)))
                    .foregroundStyle(.custom(.gray(.gray90)))

                HStack(spacing: 2) {
                    AppIcon.likeFill
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(Color(hex: "#FDC020"))

                    Text("\(restaurant.pickCount)개")
                        .font(.custom(.pretendard(.body3)))
                        .foregroundStyle(.custom(.gray(.gray90)))
                }

                Spacer()
            }

            HStack(spacing: AppPadding.large.value) {
                InfoItemView(
                    icon: AppIcon.distance,
                    text: String(format: "%.1fkm", restaurant.distance ?? 0.0)
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
        }
        .padding(.vertical, .small)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity)
        .background(.custom(.gray(.gray0)))
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
                .font(.custom(.pretendard(.caption1)))
                .foregroundStyle(.custom(.gray(.gray75)))
        }

    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(white: 0.95).edgesIgnoringSafeArea(.all)
        PopularRestaurantItemView(
            restaurant: Restaurant(
                restaurantId: "1",
                category: .cafe,
                name: "스타벅스 강남점",
                close: "22:00",
                restaurantImageURLs: [],
                isPicchelin: true,
                isPick: true,
                pickCount: 120,
                hashTags: ["커피", "디저트"],
                totalRating: 4.5,
                totalOrderCount: 1500,
                totalReviewCount: 300,
                geolocation: Geolocation(longitude: 127.0, latitude: 37.5),
                distance: 0.5,
                createdAt: Date(),
                updatedAt: Date()
            )
        ) { _, _ in
            
        }
    }
}
