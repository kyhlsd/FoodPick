//
//  ReceiptDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation
import Domain
import Core

struct ReceiptDTO: ResponseDTO {
    private let impUid: String
    private let merchantUid: String
    private let payMethod: String
    private let channel: String
    private let pgProvider: String
    private let embPgProvider: String
    private let pgTid: String
    private let pgId: String
    private let escrow: Bool
    private let applyNumber: String
    private let bankCode: String
    private let bankName: String
    private let cardCode: String
    private let cardName: String
    private let cardIssuerCode: String
    private let cardIssuerName: String
    private let cardPublisherCode: String
    private let cardPublisherName: String
    private let cardQuota: Int
    private let cardNumber: String
    private let cardType: Int
    private let vbankCode: String
    private let vbankName: String
    private let vbankNumber: String
    private let vbankHolder: String
    private let vbankDate: Int
    private let vbankIssuedAt: Int
    private let name: String
    private let amount: Int
    private let currency: String
    private let buyerName: String
    private let buyerEmail: String
    private let buyerTelephone: String
    private let buyerAddress: String
    private let buyerPostcode: String
    private let customerData: String
    private let userAgent: String
    private let status: String
    private let startedAt: String
    private let paidAt: String
    private let receiptURL: String
    private let createdAt: String
    private let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
        case merchantUid = "merchant_uid"
        case payMethod = "pay_method"
        case channel
        case pgProvider = "pg_provider"
        case embPgProvider = "emb_pg_provider"
        case pgTid = "pg_tid"
        case pgId = "pg_id"
        case escrow
        case applyNumber = "apply_num"
        case bankCode = "bank_code"
        case bankName = "bank_name"
        case cardCode = "card_code"
        case cardName = "card_name"
        case cardIssuerCode = "card_issuer_code"
        case cardIssuerName = "card_issuer_name"
        case cardPublisherCode = "card_publisher_code"
        case cardPublisherName = "card_publisher_name"
        case cardQuota = "card_quota"
        case cardNumber = "card_number"
        case cardType = "card_type"
        case vbankCode = "vbank_code"
        case vbankName = "vbank_name"
        case vbankNumber = "vbank_num"
        case vbankHolder = "vbank_holder"
        case vbankDate = "vbank_date"
        case vbankIssuedAt = "vbank_issued_at"
        case name
        case amount
        case currency
        case buyerName = "buyer_name"
        case buyerEmail = "buyer_email"
        case buyerTelephone = "buyer_tel"
        case buyerAddress = "buyer_addr"
        case buyerPostcode = "buyer_postcode"
        case customerData = "custom_data"
        case userAgent = "user_agent"
        case status
        case startedAt
        case paidAt
        case receiptURL = "receipt_url"
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.impUid = try container.decode(String.self, forKey: .impUid)
        self.merchantUid = try container.decode(String.self, forKey: .merchantUid)
        self.payMethod = try container.decode(String.self, forKey: .payMethod)
        self.channel = try container.decode(String.self, forKey: .channel)
        self.pgProvider = try container.decode(String.self, forKey: .pgProvider)
        self.embPgProvider = try container.decode(String.self, forKey: .embPgProvider)
        self.pgTid = try container.decode(String.self, forKey: .pgTid)
        self.pgId = try container.decode(String.self, forKey: .pgId)
        self.escrow = try container.decode(Bool.self, forKey: .escrow)
        self.applyNumber = try container.decode(String.self, forKey: .applyNumber)
        self.bankCode = try container.decode(String.self, forKey: .bankCode)
        self.bankName = try container.decode(String.self, forKey: .bankName)
        self.cardCode = try container.decode(String.self, forKey: .cardCode)
        self.cardName = try container.decode(String.self, forKey: .cardName)
        self.cardIssuerCode = try container.decode(String.self, forKey: .cardIssuerCode)
        self.cardIssuerName = try container.decode(String.self, forKey: .cardIssuerName)
        self.cardPublisherCode = try container.decode(String.self, forKey: .cardPublisherCode)
        self.cardPublisherName = try container.decode(String.self, forKey: .cardPublisherName)
        self.cardQuota = try container.decode(Int.self, forKey: .cardQuota)
        self.cardNumber = try container.decode(String.self, forKey: .cardNumber)
        self.cardType = try container.decode(Int.self, forKey: .cardType)
        self.vbankCode = try container.decode(String.self, forKey: .vbankCode)
        self.vbankName = try container.decode(String.self, forKey: .vbankName)
        self.vbankNumber = try container.decode(String.self, forKey: .vbankNumber)
        self.vbankHolder = try container.decode(String.self, forKey: .vbankHolder)
        self.vbankDate = try container.decode(Int.self, forKey: .vbankDate)
        self.vbankIssuedAt = try container.decode(Int.self, forKey: .vbankIssuedAt)
        self.name = try container.decode(String.self, forKey: .name)
        self.amount = try container.decode(Int.self, forKey: .amount)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.buyerName = try container.decode(String.self, forKey: .buyerName)
        self.buyerEmail = try container.decode(String.self, forKey: .buyerEmail)
        self.buyerTelephone = try container.decode(String.self, forKey: .buyerTelephone)
        self.buyerAddress = try container.decode(String.self, forKey: .buyerAddress)
        self.buyerPostcode = try container.decode(String.self, forKey: .buyerPostcode)
        self.customerData = try container.decode(String.self, forKey: .customerData)
        self.userAgent = try container.decode(String.self, forKey: .userAgent)
        self.status = try container.decode(String.self, forKey: .status)
        self.startedAt = try container.decode(String.self, forKey: .startedAt)
        self.paidAt = try container.decode(String.self, forKey: .paidAt)
        self.receiptURL = try container.decode(String.self, forKey: .receiptURL)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

extension ReceiptDTO {
    var toDomain: Receipt {
        let formatter = Core.DateFormatterProvider.iso8601
        return .init(impUid: impUid,
                     merchantUid: merchantUid,
                     payMethod: payMethod,
                     channel: channel,
                     pgProvider: pgProvider,
                     embPgProvider: embPgProvider,
                     pgTid: pgTid,
                     pgId: pgId,
                     escrow: escrow,
                     applyNumber: applyNumber,
                     bankCode: bankCode,
                     bankName: bankName,
                     cardCode: cardCode,
                     cardName: cardName,
                     cardIssuerCode: cardIssuerCode,
                     cardIssuerName: cardIssuerName,
                     cardPublisherCode: cardPublisherCode,
                     cardPublisherName: cardPublisherName,
                     cardQuota: cardQuota,
                     cardNumber: cardNumber,
                     cardType: cardType,
                     vbankCode: vbankCode,
                     vbankName: vbankName,
                     vbankNumber: vbankNumber,
                     vbankHolder: vbankHolder,
                     vbankDate: vbankDate,
                     vbankIssuedAt: vbankIssuedAt,
                     name: name,
                     amount: amount,
                     currency: currency,
                     buyerName: buyerName,
                     buyerEmail: buyerEmail,
                     buyerTelephone: buyerTelephone,
                     buyerAddress: buyerAddress,
                     buyerPostcode: buyerPostcode,
                     customerData: customerData,
                     userAgent: userAgent,
                     status: status,
                     startedAt: formatter.date(from: startedAt) ?? Date(),
                     paidAt: formatter.date(from: paidAt) ?? Date(),
                     receiptURL: receiptURL,
                     createdAt: formatter.date(from: createdAt) ?? Date(),
                     updatedAt: formatter.date(from: updatedAt) ?? Date()
        )
    }
}
