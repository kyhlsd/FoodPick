//
//  GeoLocationDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct GeoLocationDTO: ResponseDTO {
    private let longitude: Float
    private let latitude: Float
}

extension GeoLocationDTO {
    var toDomain: GeoLocation {
        return .init(longitude: longitude, latitude: latitude)
    }
}
