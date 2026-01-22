//
//  DefaultLocationRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 1/13/26.
//

import Foundation
import CoreLocation
import Domain

public final class DefaultLocationRepositoryImpl: NSObject, LocationRepository, @unchecked Sendable {
    public static let shared = DefaultLocationRepositoryImpl()
    
    private let networkManager = NetworkManager.shared
    
    private let userLocationKey = "userLocation"
    private let locationManager = CLLocationManager()
    private let lock = NSLock()
    
    // 단발성 위치 조회
    private var _continuation: CheckedContinuation<Geolocation, Error>?
    // 실시간 위치 스트림
    private var _streamContinuation: AsyncStream<Geolocation>.Continuation?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }
    
    public func fetchCurrentGeolocation() async throws -> Geolocation {
        return try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            self._continuation = continuation
            lock.unlock()
            
            checkAuthorizationAndStart()
        }
    }
    
    public func locationStream() -> AsyncStream<Geolocation> {
        return AsyncStream { continuation in
            lock.lock()
            _streamContinuation?.finish()
            _streamContinuation = continuation
            lock.unlock()
            
            // 스트림 종료 작업
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                self._streamContinuation = nil
                self.lock.unlock()
                
                if self._continuation == nil {
                    self.locationManager.stopUpdatingLocation()
                }
            }
            
            checkAuthorizationAndStart()
        }
    }
    
    public func stopTracking() {
        lock.lock()
        defer { lock.unlock() }
        
        _streamContinuation?.finish()
        _streamContinuation = nil
        
        if _continuation == nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    public func reverseGeocode(geolocation: Geolocation) async throws -> String {
        let dto = GeolocationDTO(from: geolocation)
        guard let response = try await networkManager.request(
            LocationRouter.address(geolocation: dto),
            responseType: AddressResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
    
    public func saveUserLocation(userLocation: UserLocation) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(userLocation)
        UserDefaults.standard.set(data, forKey: userLocationKey)
    }
    
    public func getUserLocation() -> UserLocation? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = UserDefaults.standard.data(forKey: userLocationKey) else { return nil }
        return try? JSONDecoder().decode(UserLocation.self, from: data)
    }
    
    public func clearUserLocation() {
        UserDefaults.standard.removeObject(forKey: userLocationKey)
    }
    
    public func calculateDistance(from start: Geolocation, to end: Geolocation) -> Float {
        let startLocation = CLLocation(
            latitude: start.latitude,
            longitude: start.longitude
        )
        let endLocation = CLLocation(
            latitude: end.latitude,
            longitude: end.longitude
        )
        return Float(startLocation.distance(from: endLocation))
    }
    
    public func fetchDirections(_ directionRequest: DirectionRequest) async throws -> DirectionResponse {
        let dto = DirectionRequestDTO(from: directionRequest)
        guard let response = try await networkManager.request(
            LocationRouter.direction(dto: dto),
            responseType: DirectionResponseDTO.self
        ) else {
            throw APIError.empty
        }
        return response.toDomain
    }
}

extension DefaultLocationRepositoryImpl: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geolocation = Geolocation(
            longitude: location.coordinate.longitude,
            latitude: location.coordinate.latitude
        )
        resumeWithLocation(geolocation)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeWithError(error)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Private Helpers
    private func resumeWithLocation(_ geolocation: Geolocation) {
        lock.lock()
        let continuation = _continuation
        let streamContinuation = _streamContinuation
        
        if let continuation {
            _continuation = nil
            continuation.resume(returning: geolocation)
        }
        if let streamContinuation {
            streamContinuation.yield(geolocation)
        }
        lock.unlock()
        
        if streamContinuation == nil && continuation != nil {
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func resumeWithError(_ error: Error) {
        lock.lock()
        let continuation = _continuation
        let streamContinuation = _streamContinuation
        _continuation = nil
        _streamContinuation = nil
        lock.unlock()
        continuation?.resume(throwing: error)
        streamContinuation?.finish()
    }
    
    private func checkAuthorizationAndStart() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            resumeWithError(LocationError.locationPermissionDenied)
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            resumeWithError(LocationError.unknown)
        }
    }
}

public enum LocationError: LocalizedError {
    case locationPermissionDenied
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "위치 권한이 거부되어 있습니다."
        case .unknown:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
}
