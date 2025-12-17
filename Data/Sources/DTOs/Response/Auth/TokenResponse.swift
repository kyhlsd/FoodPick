//
//  TokenResponse.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

struct TokenResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
}
