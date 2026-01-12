//
//  Geolocation.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct Geolocation: Sendable, Codable {
    public let longitude: Float
    public let latitude: Float
    
    public init(longitude: Float, latitude: Float) {
        self.longitude = longitude
        self.latitude = latitude
    }
}
