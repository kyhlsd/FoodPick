//
//  LocationRepository.swift
//  Domain
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation

public protocol LocationRepository: Sendable {
    func fetchCurrentGeolocation() async throws -> Geolocation
    func locationStream() -> AsyncStream<Geolocation>
    func stopTracking()
    func reverseGeocode(geolocation: Geolocation) async throws -> String
    func saveUserLocation(userLocation: UserLocation) throws
    func getUserLocation() -> UserLocation?
    func clearUserLocation()
    func calculateDistance(from start: Geolocation, to end: Geolocation) -> Float
    func fetchDirections(_ directionRequest: DirectionRequest) async throws -> DirectionResponse
}
