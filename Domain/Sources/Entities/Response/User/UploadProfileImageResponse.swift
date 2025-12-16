//
//  UploadProfileImageResponse.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct UploadProfileImageResponse {
    public let profileImage: String
    
    public init(profileImage: String) {
        self.profileImage = profileImage
    }
}
