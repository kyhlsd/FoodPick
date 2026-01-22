//
//  LocationStreamUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/22/26.
//

public protocol LocationStreamUseCase: Sendable {
    func execute() -> AsyncStream<Geolocation>
}

public final class LocationStreamUseCaseImpl: LocationStreamUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute() -> AsyncStream<Geolocation> {
        return locationRepository.locationStream()
    }
}
