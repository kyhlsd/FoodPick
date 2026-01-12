//
//  UserLocation.swift
//  Domain
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation

public struct UserLocation: Sendable, Codable {
    public let address: String
    public let geolocation: Geolocation
    
    public init(address: String, geolocation: Geolocation) {
        self.address = address
        self.geolocation = geolocation
    }
    
    static let basic = UserLocation(
        address: "문래역, 영등포구",
        geolocation: .init(
            longitude: 126.8837,
            latitude: 37.5255
        )
    )
}
