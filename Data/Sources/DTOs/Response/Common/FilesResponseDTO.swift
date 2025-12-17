//
//  FilesResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/17/25.
//

import Domain

struct FilesResponseDTO: ResponseDTO {
    private let files: [String]
}

extension FilesResponseDTO {
    var toDomain: [String] {
        return files
    }
}
