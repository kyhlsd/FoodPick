//
//  Profile.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct Profile: Sendable {
    public let userId: String
    public let nickname: String
    public let profileImage: String?
    
    public init(userId: String, nickname: String, profileImage: String?) {
        self.userId = userId
        self.nickname = nickname
        self.profileImage = profileImage
    }
}
