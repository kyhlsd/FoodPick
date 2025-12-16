//
//  PostFilesResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct PostFilesResponseDTO: ResponseDTO {
    private let files: [String]
}

extension PostFilesResponseDTO {
    var toDomain: [String] {
        return files
    }
}
