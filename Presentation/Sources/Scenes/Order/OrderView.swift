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
                                        OrderHistoryItemView(order: order)
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

private struct OrderRestaurantView: View {
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

private struct OrderMenuView: View {
    let order: Order
    
    private var totalQuantity: Int {
        order.orderMenuList.reduce(0) { $0 + $1.quantity }
    }
    
    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            ForEach(order.orderMenuList,
                    id: \.menu.id) { menuItem in
                HStack(spacing: AppPadding.medium.value) {
                    // 메뉴 이미지
                    AuthenticatedImage(imagePath: menuItem.menu.menuImageURL)
                        .frame(width: 84, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray45)), lineWidth: 1)
                        )
                    
                    // 메뉴 정보
                    VStack(alignment: .leading, spacing: AppPadding.tiny.value) {
                        Text(menuItem.menu.name)
                            .font(.pretendard(size: .body2, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray90)))
                        
                        HStack(spacing: AppPadding.small.value) {
                            Text("\(menuItem.menu.price.formatted())원")
                                .font(.pretendard(size: .body2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray75)))
                            
                            Text("\(menuItem.quantity.formatted())EA")
                                .font(.pretendard(size: .body2, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))
                        }
                    }
                    
                    Spacer()
                }
                
                MyDivider()
            }
            
            // 결제 금액
            HStack(spacing: AppPadding.small.value) {
                Text("결제 금액")
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray60)))
                
                Spacer()
                
                Text("\(totalQuantity)EA")
                    .font(.pretendard(size: .body2, weight: .medium))
                    .foregroundStyle(.custom(.gray(.gray60)))
                
                Text("\(order.totalPrice.formatted())원")
                    .font(.pretendard(size: .body2, weight: .bold))
                    .foregroundStyle(.custom(.gray(.gray90)))
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

private struct OrderHistoryItemView: View {
    let order: Order
    
    private var menuSummary: String {
        guard !order.orderMenuList.isEmpty else { return "" }
        let firstMenu = order.orderMenuList[0].menu.name
        let additionalCount = order.orderMenuList.count - 1
        
        if additionalCount > 0 {
            return "\(firstMenu) 외 \(additionalCount)건"
        } else {
            return firstMenu
        }
    }
    
    var body: some View {
        VStack(spacing: AppPadding.medium.value) {
            HStack(spacing: AppPadding.medium.value) {
                VStack(alignment: .leading, spacing: AppPadding.small.value) {
                    // 가게 이름
                    Text(order.restaurant.name)
                        .font(.pretendard(size: .title1, weight: .bold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // 주문 번호
                        Text(order.orderCode)
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                        
                        // 주문 시간
                        Text(TimeFormatter.toKoreanDateTimeFormat(from: order.paidAt))
                            .font(.pretendard(size: .caption1, weight: .semiBold))
                            .foregroundStyle(.custom(.gray(.gray45)))
                    }
                    
                    HStack(spacing: 0) {
                        // 주문 메뉴
                        Text(menuSummary)
                            .font(.pretendard(size: .body3, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray60)))
                        
                        // 결제 금액
                        Text("\(order.totalPrice.formatted())원")
                            .font(.pretendard(size: .body3, weight: .bold))
                            .foregroundStyle(.custom(.brand(.blackSprout)))
                            .padding(.leading, .medium)
                        
                        // 상세 보기
                        Button {
                            // TODO: 메뉴 상세 보기
                        } label: {
                            AppIcon.chevron
                                .resizable()
                                .frame(width: 16, height: 16)
                                .rotationEffect(.degrees(180))
                                .foregroundStyle(.custom(.brand(.blackSprout)))
                        }
                    }
                }
                
                Spacer()
                
                // 가게 이미지
                AuthenticatedImage(imagePath: order.restaurant.restaurantImageURLs.first)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.custom(.gray(.gray30)), lineWidth: 1)
                    )
            }
            
            // 리뷰 버튼
            if let review = order.review {
                // TODO: 후기로 넘어가는 버튼
                Button {
                    // TODO: 후기 화면으로 이동
                } label: {
                    HStack(spacing: AppPadding.medium.value) {
                        AppIcon.starFill
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.custom(.brand(.brightForsythia)))

                        Text("\(review.rating).0")
                            .font(.pretendard(size: .body1, weight: .bold))
                            .foregroundStyle(.custom(.gray(.gray75)))
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.custom(.gray(.gray30)))
                    )
                }
                .buttonStyle(.plain)
            } else {
                // TODO: 리뷰 작성 버튼
                Button {
                    // TODO: 리뷰 작성 화면으로 이동
                } label: {
                    Text("리뷰 작성하기")
                        .font(.pretendard(size: .body2, weight: .semiBold))
                        .foregroundStyle(.custom(.gray(.gray90)))
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.custom(.gray(.gray30)))
                        )
                }
                .buttonStyle(.plain)
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
