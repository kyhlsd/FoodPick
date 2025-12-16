//
//  StoreListResponse.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct StoreListResponse: ResponseDTO {
    private let data: [StoreDTO]
}

extension StoreListResponse {
    var toDomain: [Store] {
        return data.map { $0.toDomain }
    }
}
