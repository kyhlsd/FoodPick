//
//  OrderDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct OrderDetailView: View {
    let store: StoreOf<OrderDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let order = store.order

            ScrollView {
                VStack(spacing: AppPadding.large.value) {
                    // 가게 정보
                    RestaurantSection(restaurant: order.restaurant)

                    MyDivider()

                    // 주문 번호
                    OrderCodeSection(orderCode: order.orderCode)

                    MyDivider()

                    // 주문 상태 타임라인
                    OrderStatusSection(
                        currentStatus: order.currentOrderStatus,
                        timeline: order.orderStatusTimeline
                    )

                    MyDivider()
                    
                    // 주문 메뉴
                    OrderMenuSection(menuList: order.orderMenuList)

                    MyDivider()

                    // 결제 정보
                    PaymentSection(
                        totalPrice: order.totalPrice,
                        paidAt: order.paidAt
                    )

                    // 하단 여백
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 20)
                }
                .padding(.horizontal, .xLarge)
            }
            .background(Color.custom(.gray(.gray0)))
            .navigationTitle("주문 상세")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - Restaurant Section
private struct RestaurantSection: View {
    let restaurant: RestaurantBasic

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            // 가게 이미지
            AuthenticatedImage(imagePath: restaurant.restaurantImageURLs.first)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                Text(restaurant.name)
                    .font(.pretendard(size: .title1, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                Text(restaurant.category.rawValue)
                    .font(.pretendard(size: .body3, weight: .regular))
                    .foregroundStyle(.custom(.gray(.gray60)))
            }

            Spacer()
        }
    }
}

// MARK: - Order Code Section
private struct OrderCodeSection: View {
    let orderCode: String

    var body: some View {
        HStack(spacing: AppPadding.small.value) {
            Text("주문 번호")
                .font(.pretendard(size: .body2, weight: .semiBold))
                .foregroundStyle(.custom(.gray(.gray75)))
            
            Spacer()

            Text(orderCode)
                .font(.pretendard(size: .title1, weight: .bold))
                .foregroundStyle(.custom(.brand(.blackSprout)))
        }
    }
}

// MARK: - Order Status Section
private struct OrderStatusSection: View {
    let currentStatus: OrderStatus
    let timeline: [OrderStatusTimelineItem]

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("주문 진행 상황")
                .font(.pretendard(size: .body2, weight: .semiBold))
                .foregroundStyle(.custom(.gray(.gray75)))

            VStack(spacing: 0) {
                ForEach(Array(timeline.enumerated()), id: \.offset) { index, item in
                    OrderStatusRow(
                        item: item,
                        isLast: index == timeline.count - 1
                    )
                }
            }
        }
    }
}

// MARK: - Order Status Row
private struct OrderStatusRow: View {
    let item: OrderStatusTimelineItem
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppPadding.medium.value) {
            // 상태 인디케이터
            VStack(spacing: 0) {
                Circle()
                    .fill(.custom(.brand(.blackSprout)))
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(Color.custom(.gray(.gray30)))
                        .frame(width: 4, height: 24)
                }
            }

            // 상태 정보
            HStack {
                Text(item.status.rawValue)
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray90)))

                Spacer()
                
                if let changedAt = item.changedAt {
                    Text(TimeFormatter.toKoreanDateTimeFormat(from: changedAt))
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray45)))
                }
            }
            .offset(y: -2)
        }
    }
}

// MARK: - Order Menu Section
private struct OrderMenuSection: View {
    let menuList: [MenuForOrder]

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("주문 메뉴")
                .font(.pretendard(size: .body2, weight: .semiBold))
                .foregroundStyle(.custom(.gray(.gray75)))

            VStack(spacing: AppPadding.medium.value) {
                ForEach(menuList, id: \.menu.id) { menuItem in
                    OrderMenuItem(menuItem: menuItem)
                }
            }
        }
    }
}

// MARK: - Order Menu Item
private struct OrderMenuItem: View {
    let menuItem: MenuForOrder

    private var totalPrice: Int {
        menuItem.menu.price * menuItem.quantity
    }

    var body: some View {
        HStack(spacing: AppPadding.medium.value) {
            // 메뉴 이미지
            AuthenticatedImage(imagePath: menuItem.menu.menuImageURL)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // 메뉴 정보
            VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                Text(menuItem.menu.name)
                    .font(.pretendard(size: .body2, weight: .semiBold))
                    .foregroundStyle(.custom(.gray(.gray90)))

                HStack(spacing: AppPadding.tiny.value) {
                    Text("\(menuItem.menu.price.formatted())원")
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))

                    Text("·")
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray45)))

                    Text("\(menuItem.quantity)EA")
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))
                }
            }

            Spacer()

            // 총 가격
            Text("\(totalPrice.formatted())원")
                .font(.pretendard(size: .body2, weight: .semiBold))
                .foregroundStyle(.custom(.gray(.gray90)))
        }
    }
}

// MARK: - Payment Section
private struct PaymentSection: View {
    let totalPrice: Int
    let paidAt: Date

    var body: some View {
        VStack(alignment: .leading, spacing: AppPadding.medium.value) {
            Text("결제 정보")
                .font(.pretendard(size: .body2, weight: .semiBold))
                .foregroundStyle(.custom(.gray(.gray75)))

            VStack(spacing: AppPadding.small.value) {
                HStack {
                    Text("총 결제 금액")
                        .font(.pretendard(size: .body2, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray75)))

                    Spacer()

                    Text("\(totalPrice.formatted())원")
                        .font(.pretendard(size: .title1, weight: .bold))
                        .foregroundStyle(.custom(.brand(.blackSprout)))
                }

                HStack {
                    Text("결제 일시")
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray60)))

                    Spacer()

                    Text(TimeFormatter.toFullWithDotTimeFormat(from: paidAt))
                        .font(.pretendard(size: .body3, weight: .regular))
                        .foregroundStyle(.custom(.gray(.gray75)))
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OrderDetailView(
            store: Store(
                initialState: OrderDetailFeature.State(
                    order: Order(
                        orderId: "1",
                        orderCode: "A1234",
                        totalPrice: 17000,
                        review: nil,
                        restaurant: RestaurantBasic(
                            restaurantId: "1",
                            category: .korean,
                            name: "맛있는 음식점",
                            close: "22:00",
                            restaurantImageURLs: [],
                            geolocation: Geolocation(longitude: 127.0, latitude: 37.0),
                            createdAt: Date(),
                            updatedAt: Date()
                        ),
                        orderMenuList: [
                            MenuForOrder(
                                menu: MenuDetailForOrder(
                                    id: "1",
                                    category: "메인",
                                    name: "김치찌개",
                                    description: "맛있는 김치찌개",
                                    originInformation: "국내산",
                                    price: 8000,
                                    tags: ["한식", "찌개"],
                                    menuImageURL: nil,
                                    createdAt: Date(),
                                    updatedAt: Date()
                                ),
                                quantity: 2
                            ),
                            MenuForOrder(
                                menu: MenuDetailForOrder(
                                    id: "2",
                                    category: "사이드",
                                    name: "공기밥",
                                    description: "고슬고슬한 밥",
                                    originInformation: "국내산",
                                    price: 1000,
                                    tags: ["밥"],
                                    menuImageURL: nil,
                                    createdAt: Date(),
                                    updatedAt: Date()
                                ),
                                quantity: 1
                            )
                        ],
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
                                changedAt: Date().addingTimeInterval(-3000)
                            ),
                            OrderStatusTimelineItem(
                                status: .inProgress,
                                completed: true,
                                changedAt: Date().addingTimeInterval(-1800)
                            ),
                            OrderStatusTimelineItem(
                                status: .ready,
                                completed: false,
                                changedAt: nil
                            ),
                            OrderStatusTimelineItem(
                                status: .pickedUp,
                                completed: false,
                                changedAt: nil
                            )
                        ],
                        paidAt: Date().addingTimeInterval(-3600),
                        createdAt: Date().addingTimeInterval(-3600),
                        updatedAt: Date().addingTimeInterval(-1800)
                    )
                )
            ) {
                OrderDetailFeature()
            }
        )
    }
}
