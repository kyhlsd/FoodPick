//
//  SearchUserResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct SearchUserResponseDTO: ResponseDTO {
    private let data: [ProfileDTO]
}

extension SearchUserResponseDTO {
    var toDomain: [Profile] {
        return data.map { $0.toDomain }
    }
}
