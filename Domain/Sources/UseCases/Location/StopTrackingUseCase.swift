//
//  StopTrackingUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/22/26.
//

public protocol StopTrackingUseCase: Sendable {
    func execute()
}

public final class StopTrackingUseCaseImpl: StopTrackingUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute() {
        locationRepository.stopTracking()
    }
}
