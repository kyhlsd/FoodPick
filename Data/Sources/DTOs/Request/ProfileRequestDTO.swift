//
//  ProfileRequestDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ProfileRequestDTO: Encodable {
    private let nick: String?
    private let phoneNum: String?
    private let profileImage: String?
}

extension ProfileRequestDTO {
    init(from domain: ProfileRequest) {
        self.init(nick: domain.nickname, phoneNum: domain.phoneNumber, profileImage: domain.profileImage)
    }
}
