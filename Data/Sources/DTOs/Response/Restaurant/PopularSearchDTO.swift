//
//  PopularSearchDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

struct PopularSearchDTO: ResponseDTO {
    private let data: [String]
}

extension PopularSearchDTO {
    var toDomain: [String] {
        return data
    }
}
