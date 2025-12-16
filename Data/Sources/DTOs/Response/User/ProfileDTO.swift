//
//  ProfileDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ProfileDTO: ResponseDTO {
    private let userId: String
    private let nickname: String
    private let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nick"
        case profileImage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
}

extension ProfileDTO {
    var toDomain: Profile {
        return .init(userId: userId, nickname: nickname, profileImage: profileImage)
    }
}
