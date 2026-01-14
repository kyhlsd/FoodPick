//
//  CalculateDistanceFromCurrentUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation

public protocol CalculateDistanceFromCurrentUseCase: Sendable {
    func execute(geoLocation: Geolocation) -> Float
}

public final class CalculateDistanceFromCurrentUseCaseImpl: CalculateDistanceFromCurrentUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute(geoLocation: Geolocation) -> Float {
        let current = locationRepository.getUserLocation() ?? UserLocation.basic
        let distance = locationRepository.calculateDistance(from: current.geolocation, to: geoLocation)
        
        return distance
    }
}
