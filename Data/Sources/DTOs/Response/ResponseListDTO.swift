//
//  ResponseListDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct ResponseListDTO<T: ResponseDTO>: ResponseDTO {
    private let data: [T]
}

extension ResponseListDTO {
    var toDomain: [T.Entity] {
        return data.map { $0.toDomain }
    }
}
