//
//  GeolocationDTO.swift
//  Data
//
//  Created by 김영훈 on 12/16/25.
//

import Domain

struct GeolocationDTO: ResponseDTO {
    let longitude: Float
    let latitude: Float
}

extension GeolocationDTO {
    var toDomain: Geolocation {
        return .init(longitude: longitude, latitude: latitude)
    }
    
    init(from geolocation: Geolocation) {
        longitude = geolocation.longitude
        latitude = geolocation.latitude
    }
}
