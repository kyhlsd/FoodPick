//
//  GetUserLocationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation

public protocol GetUserLocationUseCase: Sendable {
    func execute() -> UserLocation
}

public final class GetUserLocationUseCaseImpl: GetUserLocationUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute() -> UserLocation {
        return locationRepository.getUserLocation() ?? UserLocation.basic
    }
}
