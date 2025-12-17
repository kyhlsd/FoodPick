//
//  FetchReceiptUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol FetchReceiptUseCase: Sendable {
    func execute(orderCode: String) async throws -> Receipt
}

public final class FetchReceiptUseCaseImpl: FetchReceiptUseCase, @unchecked Sendable {
    private let paymentRepository: PaymentRepository

    public init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    public func execute(orderCode: String) async throws -> Receipt {
        return try await paymentRepository.fetchReceipt(orderCode: orderCode)
    }
}
