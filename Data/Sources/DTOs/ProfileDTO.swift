//
//  ProfileDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ProfileDTO: Decodable, Sendable {
    private let user_id: String
    private let nick: String
    private let profileImage: String?
}

extension ProfileDTO {
    var toDomain: Profile {
        return .init(userId: user_id, nickname: nick, profileImage: profileImage)
    }
}
