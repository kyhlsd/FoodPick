//
//  LoginResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct LoginResponseDTO: Decodable, Sendable {
    private let user_id: String
    private let email: String
    private let nick: String
    private let profileImage: String?
    private let accessToken: String
    private let refreshToken: String
}

extension LoginResponseDTO {
    var toDomain: LoginResponse {
        return .init(userId: user_id, email: email, nickname: nick, profileImage: profileImage, accessToken: accessToken, refreshToken: refreshToken)
    }
}
