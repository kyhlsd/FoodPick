//
//  OrderView.swift
//  Presentation
//
//  Created by 김영훈 on 1/1/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct OrderView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack {
                    MessageText()
                        .padding(.bottom, .xLarge)
                }
                .background(.custom(.gray(.gray0)))
                
                MyDivider()
                
                VStack(spacing: AppPadding.large.value) {
                    HStack {
                        Text("주문 현황")
                            .font(.pretendard(size: .body2, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                        
                        Spacer()
                    }
                    .padding(.top, .xLarge)
                    
                    OrderRestaurantView(order: sampleOrder)
                }
                .padding(.horizontal, .xLarge)
                .background(.custom(.gray(.gray15)))
                
                Spacer()
            }
        }
    }
}

private struct MessageText: View {
    var body: some View {
        Text(Self.attributedString)
            .padding(.horizontal, .xLarge)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.custom(.brand(.brightSprout)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.custom(.brand(.deepSprout)), lineWidth: 1)
            )
            .shadow(color: .init(hex: "#525156").opacity(0.2),
                    radius: 12,
                    x: 0,
                    y: 4
            )
    }
    
    private static let attributedString: AttributedString = {
        var text = AttributedString("픽업을 하실 때는 주문번호를 꼭 말씀해주세요!")
        
        text.foregroundColor = .custom(.brand(.deepSprout))
        text.font = .jalnan(.caption1) // Font 타입 변환 필요할 수 있음
        
        if let range = text.range(of: "픽업") {
            text[range].foregroundColor = .custom(.brand(.blackSprout))
        }
        
        if let range = text.range(of: "주문번호") {
            text[range].foregroundColor = .custom(.brand(.blackSprout))
        }
        
        return text
    }()
}

private struct OrderRestaurantView: View {
    let order: Order

    private var formattedPaidAt: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 "
        let dateString = formatter.string(from: order.paidAt)
        let timeString = TimeFormatter.toKoreanAMPMFormat(from: order.paidAt)
        return dateString + timeString
    }

    var body: some View {
        VStack(spacing: AppPadding.small.value) {
            HStack(spacing: AppPadding.large.value) {
                // 주문 가게
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: AppPadding.tiny.value) {
                        Text("주문번호")
                            .font(.jalnan(.caption1))
                            .foregroundStyle(.custom(.gray(.gray45)))

                        Text(order.orderCode)
                            .font(.jalnan(.caption1))
                            .foregroundStyle(.custom(.gray(.gray60)))
                    }

                    Text(order.restaurant.name)
                        .font(.jalnan(.body1))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                        .padding(.top, .small)

                    Text(formattedPaidAt)
                        .font(.pretendard(size: .caption2, weight: .semiBold))
                        .foregroundStyle(.custom(.brand(.brightSprout)))
                        .padding(.top, .tiny)

                    AuthenticatedImage(imagePath: order.restaurant.restaurantImageURLs.first)
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray45)), lineWidth: 1)
                        )
                        .padding(.top, .medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 주문 상태
                VStack(spacing: 0) {
                    ForEach(Array(order.orderStatusTimeline.enumerated()), id: \.element.status) { index, timelineItem in

                        HStack(alignment: .top, spacing: AppPadding.small.value) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(timelineItem.completed
                                        ? .custom(.brand(.blackSprout))
                                        : .custom(.gray(.gray30)))
                                    .frame(width: 16, height: 16)
                                    .overlay {
                                        if timelineItem.completed {
                                            AppIcon.check
                                                .resizable()
                                                .frame(width: 10, height: 10)
                                                .foregroundStyle(.custom(.gray(.gray0)))
                                        } else {
                                            Circle()
                                                .fill(.custom(.gray(.gray0)))
                                                .frame(width: 8, height: 8)
                                        }
                                    }

                                // 마지막이 아니면 연결선
                                if index != order.orderStatusTimeline.count - 1 {
                                    Rectangle()
                                        .fill(
                                            timelineItem.status == order.currentOrderStatus
                                                ? .custom(.gray(.gray30))
                                                : (timelineItem.completed
                                                    ? .custom(.brand(.blackSprout))
                                                    : .custom(.gray(.gray30)))
                                        )
                                        .frame(width: 4)
                                }
                            }

                            Text(timelineItem.status.rawValue)
                                .font(.pretendard(size: .caption2, weight: .semiBold))
                                .foregroundStyle(.custom(.gray(.gray90)))
                                .frame(width: 40, alignment: .leading)
                                .offset(y: 2)

                            Text(TimeFormatter.toKoreanAMPMFormat(from: timelineItem.changedAt))
                                .font(.pretendard(size: .caption2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))
                                .offset(y: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.all, .large)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.custom(.gray(.gray15)))
                )
            }
        }
        .padding(.all, .large)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.custom(.gray(.gray0)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.custom(.brand(.brightSprout)), lineWidth: 1)
        )
        .shadow(color: .init(hex: "#7B7886").opacity(0.08),
                radius: 12,
                x: 0,
                y: 4
        )
    }
}

#Preview {
    OrderView()
}

// MARK: - Sample Data
private let sampleOrder = Order(
    orderId: "1",
    orderCode: "A4922",
    totalPrice: 15000,
    review: nil,
    restaurant: Restaurant(
        restaurantId: "1",
        category: .korean,
        name: "새싹 도넛 가게",
        close: "22:00",
        restaurantImageURLs: [],
        isPicchelin: false,
        isPick: false,
        pickCount: 0,
        hashTags: [],
        totalRating: 4.5,
        totalOrderCount: 100,
        totalReviewCount: 50,
        geolocation: Geolocation(longitude: 0, latitude: 0),
        distance: nil,
        createdAt: Date(),
        updatedAt: Date()
    ),
    orderMenuList: [],
    currentOrderStatus: .inProgress,
    orderStatusTimeline: [
        OrderStatusTimelineItem(
            status: .pending,
            completed: true,
            changedAt: Date().addingTimeInterval(-3600)
        ),
        OrderStatusTimelineItem(
            status: .approved,
            completed: true,
            changedAt: Date().addingTimeInterval(-2400)
        ),
        OrderStatusTimelineItem(
            status: .inProgress,
            completed: true,
            changedAt: Date().addingTimeInterval(-1800)
        ),
        OrderStatusTimelineItem(
            status: .ready,
            completed: false,
            changedAt: Date()
        ),
        OrderStatusTimelineItem(
            status: .pickedUp,
            completed: false,
            changedAt: Date()
        )
    ],
    paidAt: Date().addingTimeInterval(-7200),
    createdAt: Date(),
    updatedAt: Date()
)
