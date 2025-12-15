//
//  ProfileRequest.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct ProfileRequest {
    public let nickname: String?
    public let phoneNumber: String?
    public let profileImage: String?
    
    public init(nickname: String, phoneNumber: String, profileImage: String) {
        self.nickname = nickname
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
    }
}
