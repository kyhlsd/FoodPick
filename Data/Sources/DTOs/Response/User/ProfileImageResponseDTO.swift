//
//  ProfileImageResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ProfileImageResponseDTO: ResponseDTO {
    private let profileImage: String
}

extension ProfileImageResponseDTO {
    var toDomain: ProfileImageResponse {
        return .init(profileImage: profileImage)
    }
}
