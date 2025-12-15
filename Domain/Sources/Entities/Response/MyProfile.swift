//
//  MyProfile.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct MyProfile {
    public let userId: String
    public let email: String
    public let nickname: String
    public let profileImage: String?
    public let phoneNumber: String
    
    public init(userId: String, email: String, nickname: String, profileImage: String?, phoneNumber: String) {
        self.userId = userId
        self.email = email
        self.nickname = nickname
        self.profileImage = profileImage
        self.phoneNumber = phoneNumber
    }
}
