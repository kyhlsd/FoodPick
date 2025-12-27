//
//  PaymentView.swift
//  Presentation
//
//  Created by 김영훈 on 12/28/25.
//

import SwiftUI
import Domain
import ComposableArchitecture

struct PaymentView: View {
    let store: StoreOf<PaymentFeature>

    var body: some View {
        WithPerceptionTracking {
            @Perception.Bindable var store = store

            let paymentRequest = store.paymentRequest
            let isProcessing = store.isProcessing

            ZStack {
                // Iamport 결제 화면
                IamportPaymentView(paymentRequest: paymentRequest) { response in
                    store.send(.paymentCompleted(response))
                }

                // 결제 검증 중 로딩
                if isProcessing {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: AppPadding.medium.value) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)

                        Text("결제 검증 중...")
                            .font(.pretendard(size: .body1, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.all, .xLarge)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.7))
                    )
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .navigationTitle("결제하기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PaymentView(
            store: Store(
                initialState: PaymentFeature.State(
                    paymentRequest: PaymentRequest(
                        merchantUID: "restaurantId_\(Int(Date().timeIntervalSince1970))",
                        amount: 15000,
                        name: "아메리카노 외 1건"
                    )
                )
            ) {
                PaymentFeature()
            }
        )
    }
}
