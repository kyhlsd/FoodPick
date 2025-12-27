//
//  CreatePaymentRequestUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation

public protocol CreatePaymentRequestUseCase: Sendable {
    func execute(orderCode: String, menuNames: [String], totalAmount: Int) -> PaymentRequest
}

public struct CreatePaymentRequestUseCaseImpl: CreatePaymentRequestUseCase {
    public init() {}

    public func execute(orderCode: String, menuNames: [String], totalAmount: Int) -> PaymentRequest {
        let paymentName = menuNames.count > 1
            ? "\(menuNames[0]) 외 \(menuNames.count - 1)건"
            : menuNames.first ?? "주문"

        return PaymentRequest(
            merchantUID: orderCode,
            amount: totalAmount,
            name: paymentName,
            buyerName: "김영훈"
        )
    }
}
