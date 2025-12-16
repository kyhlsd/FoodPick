//
//  LoginResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct LoginResponseDTO: Decodable, Sendable {
    private let userId: String
    private let email: String
    private let nickname: String
    private let profileImage: String?
    private let accessToken: String
    private let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nickname = "nick"
        case profileImage
        case accessToken
        case refreshToken
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decode(String.self, forKey: .email)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}

extension LoginResponseDTO {
    var toDomain: LoginResponse {
        return .init(userId: userId,
                     email: email,
                     nickname: nickname,
                     profileImage: profileImage,
                     accessToken: accessToken,
                     refreshToken: refreshToken)
    }
}
