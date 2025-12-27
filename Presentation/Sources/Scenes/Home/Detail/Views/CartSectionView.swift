//
//  CartSectionView.swift
//  Presentation
//
//  Created by 김영훈 on 12/27/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Cart Section View
struct CartSectionView: View {
    let store: StoreOf<CartSectionFeature>

    var body: some View {
        WithPerceptionTracking {
            let cartTotalCount = store.cartTotalCount
            let cartTotalPrice = store.cartTotalPrice

            if cartTotalCount > 0 {
                VStack(spacing: 0) {
                    MyDivider()

                    HStack(spacing: AppPadding.medium.value) {
                        // 왼쪽: 총 금액
                        VStack(alignment: .leading, spacing: 4) {
                            Text("총 금액")
                                .font(.pretendard(size: .caption1, weight: .medium))
                                .foregroundStyle(.custom(.gray(.gray60)))

                            Text("\(cartTotalPrice.formatted())원")
                                .font(.pretendard(size: .title1, weight: .bold))
                                .foregroundStyle(.custom(.gray(.gray90)))
                        }

                        Spacer()

                        // 오른쪽: 결제하기 버튼
                        Button {
                            store.send(.checkoutTapped)
                        } label: {
                            HStack(spacing: AppPadding.small.value) {
                                ZStack {
                                    Circle()
                                        .fill(.custom(.gray(.gray0)))
                                        .frame(width: 16, height: 16)

                                    Text("\(cartTotalCount)")
                                        .font(.pretendard(size: .caption1, weight: .semiBold))
                                        .foregroundStyle(.custom(.brand(.blackSprout)))
                                }
                                
                                Text("결제하기")
                                    .font(.pretendard(size: .body1, weight: .bold))
                            }
                            .foregroundStyle(.custom(.gray(.gray0)))
                            .padding(.horizontal, AppPadding.large.value)
                            .padding(.vertical, AppPadding.medium.value)
                            .background(.custom(.brand(.blackSprout)))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, .xLarge)
                    .padding(.vertical, .medium)
                    .background(.custom(.gray(.gray0)))
                }
                .shadow(color: .custom(.gray(.gray75)).opacity(0.1), radius: 12)
            }
        }
    }
}
