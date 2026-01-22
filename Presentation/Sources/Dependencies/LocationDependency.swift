//
//  LocationDependency.swift
//  Presentation
//
//  Created by 김영훈 on 1/13/26.
//

import Domain
import Data
import ComposableArchitecture

extension DependencyValues {

    // MARK: - Repository
    var locationRepository: LocationRepository {
        get { self[LocationRepositoryKey.self] }
        set { self[LocationRepositoryKey.self] = newValue }
    }

    // MARK: - UseCases
    var getUserLocation: GetUserLocationUseCase {
        get { self[GetUserLocationKey.self] }
        set { self[GetUserLocationKey.self] = newValue }
    }

    var updateLocation: UpdateUserLocationUseCase {
        get { self[UpdateLocationKey.self] }
        set { self[UpdateLocationKey.self] = newValue }
    }

    var calculateDistanceFromCurrent: CalculateDistanceFromCurrentUseCase {
        get { self[CalculateDistanceFromCurrentKey.self] }
        set { self[CalculateDistanceFromCurrentKey.self] = newValue }
    }
    
    var fetchDirections: FetchDirectionsUseCase {
        get { self[FetchDirectionsKey.self] }
        set { self[FetchDirectionsKey.self] = newValue }
    }
    
    var locationStream: LocationStreamUseCase {
        get { self[LocationStreamKey.self] }
        set { self[LocationStreamKey.self] = newValue }
    }
    
    var stopTracking: StopTrackingUseCase {
        get { self[StopTrackingKey.self] }
        set { self[StopTrackingKey.self] = newValue }
    }
}

// MARK: - Keys
private enum LocationRepositoryKey: DependencyKey {
    static let liveValue: LocationRepository = DefaultLocationRepositoryImpl.shared
}

private enum GetUserLocationKey: DependencyKey {
    static let liveValue: GetUserLocationUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return GetUserLocationUseCaseImpl(locationRepository: locationRepository)
    }()
}

private enum UpdateLocationKey: DependencyKey {
    static let liveValue: UpdateUserLocationUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return UpdateLocationUseCaseImpl(locationRepository: locationRepository)
    }()
}

private enum CalculateDistanceFromCurrentKey: DependencyKey {
    static let liveValue: CalculateDistanceFromCurrentUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return CalculateDistanceFromCurrentUseCaseImpl(locationRepository: locationRepository)
    }()
}

private enum FetchDirectionsKey: DependencyKey {
    static let liveValue: FetchDirectionsUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return FetchDirectionsUseCaseImpl(locationRepository: locationRepository)
    }()
}

private enum LocationStreamKey: DependencyKey {
    static let liveValue: LocationStreamUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return LocationStreamUseCaseImpl(locationRepository: locationRepository)
    }()
}

private enum StopTrackingKey: DependencyKey {
    static let liveValue: StopTrackingUseCase = {
        @Dependency(\.locationRepository) var locationRepository
        return StopTrackingUseCaseImpl(locationRepository: locationRepository)
    }()
}
