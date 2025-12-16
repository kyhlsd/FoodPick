//
//  GeolocationDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct GeolocationDTO: ResponseDTO {
    private let longitude: Float
    private let latitude: Float
}

extension GeolocationDTO {
    var toDomain: Geolocation {
        return .init(longitude: longitude, latitude: latitude)
    }
}
