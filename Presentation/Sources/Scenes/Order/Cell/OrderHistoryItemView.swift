//
//  OrderHistoryItemView.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import SwiftUI
import Domain

struct OrderHistoryItemView: View {
    let order: Order
    let onWriteReviewTapped: () -> Void
    let onViewReviewDetailTapped: () -> Void
    let onViewOrderDetailTapped: () -> Void
    
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
                            onViewOrderDetailTapped()
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
                // 후기 상세로 넘어가는 버튼
                Button {
                    onViewReviewDetailTapped()
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
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                // 리뷰 작성 버튼
                Button {
                    onWriteReviewTapped()
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
                        .contentShape(Rectangle())
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
