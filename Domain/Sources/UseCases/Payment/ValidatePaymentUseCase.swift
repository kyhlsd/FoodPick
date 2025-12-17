//
//  ValidatePaymentUseCase.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol ValidatePaymentUseCase: Sendable {
    func execute(impUid: String) async throws -> ValidatePaymentResponse
}

public final class ValidatePaymentUseCaseImpl: ValidatePaymentUseCase, @unchecked Sendable {
    private let paymentRepository: PaymentRepository

    public init(paymentRepository: PaymentRepository) {
        self.paymentRepository = paymentRepository
    }

    public func execute(impUid: String) async throws -> ValidatePaymentResponse {
        return try await paymentRepository.validatePayment(impUid: impUid)
    }
}
