//
//  FetchDirectionsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 1/14/26.
//

import Foundation

public protocol FetchDirectionsUseCase: Sendable {
    func execute(_ directionRequest: DirectionRequest) async throws -> DirectionResponse
}

public final class FetchDirectionsUseCaseImpl: FetchDirectionsUseCase {
    private let locationRepository: LocationRepository
    
    public init(locationRepository: LocationRepository) {
        self.locationRepository = locationRepository
    }
    
    public func execute(_ directionRequest: DirectionRequest) async throws -> DirectionResponse {
        let response = try await locationRepository.fetchDirections(directionRequest)
        return response
    }
}
