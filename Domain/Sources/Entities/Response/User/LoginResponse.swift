//
//  LoginResponse.swift
//  Core
//
//  Created by 김영훈 on 12/16/25.
//

public struct LoginResponse {
    public let userId: String
    public let email: String
    public let nickname: String
    public let profileImage: String?
    public let accessToken: String
    public let refreshToken: String
    
    public init(userId: String, email: String, nickname: String, profileImage: String?, accessToken: String, refreshToken: String) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
