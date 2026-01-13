//
//  UpdateLocationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation

public protocol UpdateUserLocationUseCase: Sendable {
    func execute() async throws -> UserLocation
}

public final class UpdateLocationUseCaseImpl: UpdateUserLocationUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute() async throws -> UserLocation {
        let geolocation = try await locationRepository.fetchCurrentGeolocation()
        let address = try await locationRepository.reverseGeocode(geolocation: geolocation)
        let userLocation = UserLocation(address: address, geolocation: geolocation)
        try locationRepository.saveUserLocation(userLocation: userLocation)
        return userLocation
    }
}
