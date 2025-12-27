//
//  CreatePaymentRequestUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation

public protocol CreatePaymentRequestUseCase: Sendable {
    func execute(restaurantId: String, menuNames: [String], totalAmount: Int) -> PaymentRequest
}

public struct CreatePaymentRequestUseCaseImpl: CreatePaymentRequestUseCase {
    public init() {}

    public func execute(restaurantId: String, menuNames: [String], totalAmount: Int) -> PaymentRequest {
        let merchantUID = "\(restaurantId)_\(Int(Date().timeIntervalSince1970 * 1000))"

        let paymentName = menuNames.count > 1
            ? "\(menuNames[0]) 외 \(menuNames.count - 1)건"
            : menuNames.first ?? "주문"

        return PaymentRequest(
            merchantUID: merchantUID,
            amount: totalAmount,
            name: paymentName,
            buyerName: "김영훈"
        )
    }
}
