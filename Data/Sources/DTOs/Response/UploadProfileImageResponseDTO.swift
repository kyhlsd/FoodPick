//
//  UploadProfileImageResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct UploadProfileImageResponseDTO: Decodable, Sendable {
    private let profileImage: String
}

extension UploadProfileImageResponseDTO {
    var toDomain: UploadProfileImageResponse {
        return .init(profileImage: profileImage)
    }
}
