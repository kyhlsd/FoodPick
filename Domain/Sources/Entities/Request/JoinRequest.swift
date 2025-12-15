//
//  JoinRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct JoinRequest {
    public let email: String
    public let password: String
    public let nickname: String
    public let phoneNumber: String
    
    public init(email: String, password: String, nickname: String, phoneNumber: String) {
        self.email = email
        self.password = password
        self.nickname = nickname
        self.phoneNumber = phoneNumber
    }
}
