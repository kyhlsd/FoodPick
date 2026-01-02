//
//  OrderMenuView.swift
//  Presentation
//
//  Created by 김영훈 on 1/2/26.
//

import SwiftUI
import Domain

struct OrderMenuView: View {
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
