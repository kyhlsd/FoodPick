//
//  Receipt.swift
//  Domain
//
//  Created by 김영훈 on 12/17/25.
//

import Foundation

public struct Receipt: Sendable {
    public let impUid: String
    public let merchantUid: String
    public let payMethod: String
    public let channel: String
    public let pgProvider: String
    public let embPgProvider: String
    public let pgTid: String
    public let pgId: String
    public let escrow: Bool
    public let applyNumber: String
    public let bankCode: String
    public let bankName: String
    public let cardCode: String
    public let cardName: String
    public let cardIssuerCode: String
    public let cardIssuerName: String
    public let cardPublisherCode: String
    public let cardPublisherName: String
    public let cardQuota: Int
    public let cardNumber: String
    public let cardType: Int
    public let vbankCode: String
    public let vbankName: String
    public let vbankNumber: String
    public let vbankHolder: String
    public let vbankDate: Int
    public let vbankIssuedAt: Int
    public let name: String
    public let amount: Int
    public let currency: String
    public let buyerName: String
    public let buyerEmail: String
    public let buyerTelephone: String
    public let buyerAddress: String
    public let buyerPostcode: String
    public let customerData: String
    public let userAgent: String
    public let status: String
    public let startedAt: Date
    public let paidAt: Date
    public let receiptURL: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(impUid: String, merchantUid: String, payMethod: String, channel: String, pgProvider: String, embPgProvider: String, pgTid: String, pgId: String, escrow: Bool, applyNumber: String, bankCode: String, bankName: String, cardCode: String, cardName: String, cardIssuerCode: String, cardIssuerName: String, cardPublisherCode: String, cardPublisherName: String, cardQuota: Int, cardNumber: String, cardType: Int, vbankCode: String, vbankName: String, vbankNumber: String, vbankHolder: String, vbankDate: Int, vbankIssuedAt: Int, name: String, amount: Int, currency: String, buyerName: String, buyerEmail: String, buyerTelephone: String, buyerAddress: String, buyerPostcode: String, customerData: String, userAgent: String, status: String, startedAt: Date, paidAt: Date, receiptURL: String, createdAt: Date, updatedAt: Date) {
        self.impUid = impUid
        self.merchantUid = merchantUid
        self.payMethod = payMethod
        self.channel = channel
        self.pgProvider = pgProvider
        self.embPgProvider = embPgProvider
        self.pgTid = pgTid
        self.pgId = pgId
        self.escrow = escrow
        self.applyNumber = applyNumber
        self.bankCode = bankCode
        self.bankName = bankName
        self.cardCode = cardCode
        self.cardName = cardName
        self.cardIssuerCode = cardIssuerCode
        self.cardIssuerName = cardIssuerName
        self.cardPublisherCode = cardPublisherCode
        self.cardPublisherName = cardPublisherName
        self.cardQuota = cardQuota
        self.cardNumber = cardNumber
        self.cardType = cardType
        self.vbankCode = vbankCode
        self.vbankName = vbankName
        self.vbankNumber = vbankNumber
        self.vbankHolder = vbankHolder
        self.vbankDate = vbankDate
        self.vbankIssuedAt = vbankIssuedAt
        self.name = name
        self.amount = amount
        self.currency = currency
        self.buyerName = buyerName
        self.buyerEmail = buyerEmail
        self.buyerTelephone = buyerTelephone
        self.buyerAddress = buyerAddress
        self.buyerPostcode = buyerPostcode
        self.customerData = customerData
        self.userAgent = userAgent
        self.status = status
        self.startedAt = startedAt
        self.paidAt = paidAt
        self.receiptURL = receiptURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
