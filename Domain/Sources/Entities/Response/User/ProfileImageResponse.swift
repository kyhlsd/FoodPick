//
//  ProfileImageResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct ProfileImageResponse: Sendable {
    public let profileImage: String
    
    public init(profileImage: String) {
        self.profileImage = profileImage
    }
}
