//
//  JoinRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct JoinRequestDTO: Encodable {
    private let email: String
    private let password: String
    private let nick: String
    private let phoneNum: String
    private let deviceToken: String
}

extension JoinRequestDTO {
    init(from domain: JoinRequest) {
        self.init(email: domain.email, password: domain.password, nick: domain.nickname, phoneNum: domain.phoneNumber, deviceToken: domain.deviceToken)
    }
}
