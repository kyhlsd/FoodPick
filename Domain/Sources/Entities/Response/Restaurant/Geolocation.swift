//
//  Geolocation.swift
//  Domain
//
//  Created by 김영훈 on 12/16/25.
//

public struct Geolocation: Sendable, Codable {
    public let longitude: Double
    public let latitude: Double
    
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}
