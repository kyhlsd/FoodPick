//
//  PaymentRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/28/25.
//

import Foundation

public struct PaymentRequest: Sendable {
    public let merchantUID: String      // 주문 번호
    public let amount: Int               // 결제 금액
    public let name: String              // 결제명
    public let buyerName: String?        // 구매자 이름
    public let pg: String                // PG사
    public let payMethod: String         // 결제 수단

    public init(
        merchantUID: String,
        amount: Int,
        name: String,
        buyerName: String? = nil,
        pg: String = "html5_inicis",
        payMethod: String = "card"
    ) {
        self.merchantUID = merchantUID
        self.amount = amount
        self.name = name
        self.buyerName = buyerName
        self.pg = pg
        self.payMethod = payMethod
    }
}
