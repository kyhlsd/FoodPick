//
//  OrderRestaurantView.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import SwiftUI
import Domain

struct OrderRestaurantView: View {
    let order: Order
    
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
                    .fixedSize(horizontal: true, vertical: false)

                    Text(order.restaurant.name)
                        .font(.jalnan(.body1))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                        .layoutPriority(-1)
                        .padding(.top, .small)

                    Text(TimeFormatter.toKoreanDateTimeFormat(from: order.paidAt))
                        .font(.pretendard(size: .caption2, weight: .semiBold))
                        .foregroundStyle(.custom(.brand(.brightSprout)))
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.top, .tiny)

                    AuthenticatedImage(imagePath: order.restaurant.restaurantImageURLs.first)
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray45)), lineWidth: 1)
                        )
                        .padding(.top, .medium)
                }

                // 주문 상태
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(OrderStatus.allCases.enumerated()),
                            id: \.element) { index, status in

                        let timelineItem = order.orderStatusTimeline.first { $0.status == status }
                        let isCompleted = timelineItem?.completed ?? false
                        let changedAt = timelineItem?.changedAt

                        HStack(alignment: .top, spacing: AppPadding.small.value) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(isCompleted
                                          ? .custom(.brand(.blackSprout))
                                          : .custom(.gray(.gray30)))
                                    .frame(width: 16, height: 16)
                                    .overlay {
                                        if isCompleted {
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
                                if index != OrderStatus.allCases.count - 1 {
                                    Rectangle()
                                        .fill(
                                            status == order.currentOrderStatus
                                            ? .custom(.gray(.gray30))
                                            : (isCompleted
                                               ? .custom(.brand(.blackSprout))
                                               : .custom(.gray(.gray30)))
                                        )
                                        .frame(width: 4)
                                }
                            }

                            Text(status.rawValue)
                                .font(.pretendard(size: .caption2, weight: .semiBold))
                                .foregroundStyle(.custom(.gray(.gray90)))
                                .frame(width: 40, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                                .offset(y: 2)

                            Text(changedAt.map { TimeFormatter.toKoreanAMPMFormat(from: $0) } ?? "")
                                .font(.pretendard(size: .caption2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))
                                .lineLimit(2)
                                .offset(y: 2)
                                .layoutPriority(0)
                        }
                    }
                }
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
