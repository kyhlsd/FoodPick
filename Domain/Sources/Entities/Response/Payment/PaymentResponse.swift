//
//  PaymentResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation

public struct PaymentResponse: Sendable {
    public let isSuccess: Bool
    public let impUID: String?
    public let merchantUID: String?
    public let errorMessage: String?

    public init(
        isSuccess: Bool,
        impUID: String? = nil,
        merchantUID: String? = nil,
        errorMessage: String? = nil
    ) {
        self.isSuccess = isSuccess
        self.impUID = impUID
        self.merchantUID = merchantUID
        self.errorMessage = errorMessage
    }
}
