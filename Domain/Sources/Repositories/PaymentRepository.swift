//
//  PaymentRepository.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public protocol PaymentRepository: Sendable {
    func validatePayment(impUid: String) async throws -> ValidatePaymentResponse
    func fetchReceipt(orderCode: String) async throws -> Receipt
}
