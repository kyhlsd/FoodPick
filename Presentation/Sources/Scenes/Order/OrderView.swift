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
    let store: StoreOf<OrderFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store
            ScrollView {
                VStack(spacing: 0) {
                    if store.isLoading {
                        // 로딩 중
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                    } else {
                        VStack(spacing: AppPadding.large.value) {
                            MessageText()
                                .padding(.bottom, .xLarge)
                        }
                        .background(.custom(.gray(.gray0)))

                        MyDivider()

                        // 주문 현황 섹션 (pickedUp이 아닌 주문들)
                        if !store.currentOrders.isEmpty {
                            VStack(spacing: AppPadding.large.value) {
                                HStack {
                                    Text("주문 현황")
                                        .font(.pretendard(size: .body2, weight: .bold))
                                        .foregroundStyle(.custom(.gray(.gray60)))

                                    Spacer()
                                }
                                
                                ForEach(store.currentOrders, id: \.orderId) { order in
                                    VStack(spacing: AppPadding.medium.value) {
                                        OrderRestaurantView(order: order)
                                        
                                        OrderMenuView(order: order)
                                    }
                                }
                            }
                            .padding(.all, .xLarge)
                            .background(.custom(.gray(.gray15)))

                            MyDivider()
                        }

                        // 이전 주문 내역 섹션 (pickedUp인 주문들)
                        if !store.pastOrders.isEmpty {
                            VStack(alignment: .leading, spacing: AppPadding.large.value) {
                                Text("이전 주문 내역")
                                    .font(.pretendard(size: .body2, weight: .bold))
                                    .foregroundStyle(.custom(.gray(.gray60)))

                                VStack(spacing: AppPadding.medium.value) {
                                    ForEach(store.pastOrders, id: \.orderId) { order in
                                        OrderHistoryItemView(
                                            order: order,
                                            onWriteReviewTapped: {
                                                store.send(.writeReviewTapped(
                                                    restaurantId: order.restaurant.restaurantId,
                                                    orderCode: order.orderCode
                                                ))
                                            },
                                            onViewReviewDetailTapped: {
                                                if let review = order.review {
                                                    store.send(.viewReviewDetailTapped(
                                                        restaurantId: order.restaurant.restaurantId,
                                                        reviewId: review.id
                                                    ))
                                                }
                                            },
                                            onViewOrderDetailTapped: {
                                                store.send(.viewOrderDetailTapped(order))
                                            }
                                        )
                                    }
                                }
                                
                                // 탭바가 가리지 않도록 추가
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 110)
                            }
                            .padding(.all, .xLarge)
                            .background(.custom(.gray(.gray0)))
                        }

                        // 주문이 없는 경우
                        if store.orders.isEmpty {
                            OrderEmptyView()
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationDestination(
                item: $store.scope(state: \.destination?.reviewWrite, action: \.destination.reviewWrite)
            ) { store in
                ReviewWriteView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.reviewDetail, action: \.destination.reviewDetail)
            ) { store in
                ReviewDetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.orderDetail, action: \.destination.orderDetail)
            ) { store in
                OrderDetailView(store: store)
            }
            .onAppear {
                store.send(.onAppear)
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
            .shadow(color: .init(hex: "#525156").opacity(0.1),
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

private struct OrderEmptyView: View {
    var body: some View {
        VStack(spacing: AppPadding.tiny.value) {
            AppIcon.leaf
                .resizable()
                .frame(width: 62, height: 62)
                .foregroundStyle(.custom(.brand(.brightSprout)))

            Text("픽미를 시작해보세요")
                .font(.jalnan(.title1))
                .foregroundStyle(.custom(.brand(.brightSprout)))

            Text("건강한 픽업 생활의 시작, 픽미")
                .font(.jalnan(.caption1))
                .foregroundStyle(.custom(.brand(.brightSprout)))
        }
        .padding(.vertical, 200)
    }
}

#Preview {
    OrderView(
        store: Store(
            initialState: OrderFeature.State(
                orders: [sampleOrder]
            )
        ) {
            OrderFeature()
        }
    )
}

// MARK: - Sample Data
private let sampleOrder = Order(
    orderId: "1",
    orderCode: "A4922",
    totalPrice: 16900,
    review: .init(id: "", rating: 5),
    restaurant: RestaurantBasic(
        restaurantId: "1",
        category: .korean,
        name: "새싹 도넛 가게",
        close: "22:00",
        restaurantImageURLs: [],
        geolocation: Geolocation(longitude: 0, latitude: 0),
        createdAt: Date(),
        updatedAt: Date()
    ),
    orderMenuList: [
        MenuForOrder(
            menu: MenuDetailForOrder(
                id: "1",
                category: "메인",
                name: "새싹 도넛",
                description: "",
                originInformation: "",
                price: 3200,
                tags: [],
                menuImageURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            quantity: 2
        ),
        MenuForOrder(
            menu: MenuDetailForOrder(
                id: "2",
                category: "메인",
                name: "초코 도넛",
                description: "",
                originInformation: "",
                price: 3500,
                tags: [],
                menuImageURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            quantity: 3
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
            changedAt: Date().addingTimeInterval(-2400)
        ),
        OrderStatusTimelineItem(
            status: .inProgress,
            completed: true,
            changedAt: Date().addingTimeInterval(-1800)
        )
    ],
    paidAt: Date().addingTimeInterval(-7200),
    createdAt: Date(),
    updatedAt: Date()
)
