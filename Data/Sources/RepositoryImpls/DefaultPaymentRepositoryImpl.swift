//
//  DefaultPaymentRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain

public final class DefaultPaymentRepositoryImpl: PaymentRepository, @unchecked Sendable {
    private let networkManager = NetworkManager.shared

    public init() {}

    public func validatePayment(impUid: String) async throws -> ValidatePaymentResponse {
        guard let response = try await networkManager.request(
            PaymentRouter.validate(id: impUid),
            responseType: ValidatePaymentResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }

    public func fetchReceipt(orderCode: String) async throws -> Receipt {
        guard let response = try await networkManager.request(
            PaymentRouter.receipt(code: orderCode),
            responseType: ReceiptDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}
