//
//  MyProfileDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct MyProfileDTO: Decodable, Sendable {
    private let user_id: String
    private let email: String
    private let nick: String
    private let profileImage: String?
    private let phoneNum: String
}

extension MyProfileDTO {
    var toDomain: MyProfile {
        return .init(userId: user_id, email: email, nickname: nick, profileImage: profileImage, phoneNumber: phoneNum)
    }
}
