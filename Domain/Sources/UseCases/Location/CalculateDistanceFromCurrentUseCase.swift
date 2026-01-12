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
    private let repository: LocationRepository
    
    public init(repository: LocationRepository) {
        self.repository = repository
    }
    
    public func execute(geoLocation: Geolocation) -> Float {
        let current = repository.getUserLocation() ?? UserLocation.basic
        let distance = repository.calculateDistance(from: current.geolocation, to: geoLocation)
        
        return distance
    }
}
