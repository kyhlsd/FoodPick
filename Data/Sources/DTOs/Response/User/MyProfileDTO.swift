//
//  MyProfileDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct MyProfileDTO: ResponseDTO {
    private let userId: String
    private let email: String
    private let nickname: String
    private let profileImage: String?
    private let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nickname = "nick"
        case profileImage
        case phoneNumber = "phoneNum"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
    }
}

extension MyProfileDTO {
    var toDomain: MyProfile {
        return .init(userId: userId,
                     email: email,
                     nickname: nickname,
                     profileImage: profileImage,
                     phoneNumber: phoneNumber)
    }
}
