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
    
    private let userLocationKey = "userLocation"
    private let locationManager = CLLocationManager()
    private let lock = NSLock()
    private var _continuation: CheckedContinuation<Geolocation, Error>?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func fetchCurrentGeolocation() async throws -> Geolocation {
        return try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            self._continuation = continuation
            lock.unlock()
            
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
    
    public func reverseGeocode(geoLocation: Geolocation) async throws -> String {
        // TODO: Geocoder
        return "문래역, 영등포구"
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
            latitude: Double(start.latitude),
            longitude: Double(start.longitude)
        )
        let endLocation = CLLocation(
            latitude: Double(end.latitude),
            longitude: Double(end.longitude)
        )
        return Float(startLocation.distance(from: endLocation))
    }
}

extension DefaultLocationRepositoryImpl: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        
        let geolocation = Geolocation(
            longitude: Float(location.coordinate.longitude),
            latitude: Float(location.coordinate.latitude)
        )
        resumeWithLocation(geolocation)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeWithError(error)
    }
    
    // MARK: - Private Helpers
    private func resumeWithLocation(_ geolocation: Geolocation) {
        lock.lock()
        let continuation = _continuation
        _continuation = nil
        lock.unlock()
        continuation?.resume(returning: geolocation)
    }
    
    private func resumeWithError(_ error: Error) {
        lock.lock()
        let continuation = _continuation
        _continuation = nil
        lock.unlock()
        continuation?.resume(throwing: error)
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
