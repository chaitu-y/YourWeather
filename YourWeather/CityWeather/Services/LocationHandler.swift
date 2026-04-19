//
//  LocationHandler.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import CoreLocation
import Foundation
import UIKit

protocol LocationManagerProtocol: AnyObject {
    var locationManager: CLLocationManager? { get set }
    var locationContinuation: CheckedContinuation<CLLocation, Error>? { get set }
    var permissionContinuation: CheckedContinuation<UserLocationPermission, Error>? { get set }
    var authorizationStatus: CLAuthorizationStatus { get set }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
}

@Observable
class LocationHandler: NSObject, CLLocationManagerDelegate, LocationManagerProtocol {

    var locationManager: CLLocationManager?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var locationContinuation: CheckedContinuation<CLLocation, Error>?
    var permissionContinuation: CheckedContinuation<UserLocationPermission, Error>?
    
    var isPermissionDenied: Bool {
        checkLocationPermission() == .restrictedOrDenied
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        // Initialize locationManager once
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        }
    }
    
    /*
     withCheckedThrowingContinuation doesn’t guarantee which thread you're on.
     The async function (requestPermission) might be called from a background thread
     So < @MainActor in > ensures correctness by hopping to @MainActor without having to isloate the func to mainactor
     */
    func requestPermission() async throws -> UserLocationPermission {
        let locPermission = self.checkLocationPermission()
        guard locPermission == .notDetermined else {
            return locPermission
        }
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                self.permissionContinuation = continuation
                locationManager?.requestWhenInUseAuthorization()
            }
        }
    }
    
    /*
     withCheckedThrowingContinuation doesn’t guarantee which thread you're on.
     The async function (requestLocation) might be called from a background thread
     So < @MainActor in > ensures correctness by hopping to @MainActor without having to isloate the func to mainactor
     */
    func requestLocation() async throws -> CLLocation {
        let locPermission = self.checkLocationPermission()
        
        guard locPermission == .authorizeWhenInUse || locPermission == .authorizeOnce else {
            throw LocationError.notAuthorized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                self.locationContinuation = continuation
                locationManager?.requestLocation()
            }
        }
    }
    
    
    func checkLocationPermission() -> UserLocationPermission {
        let status = locationManager?.authorizationStatus
        var locationPermission: UserLocationPermission = .notDetermined
        switch status {
        case .notDetermined:
            locationPermission = .notDetermined
        case .restricted, .denied:
            locationPermission = .restrictedOrDenied
        case .authorizedWhenInUse:
            locationPermission = .authorizeWhenInUse
        case .authorizedAlways:
            locationPermission = .authorizeWhenInUse
        case .authorized:
            locationPermission = .authorizeWhenInUse
        case .none:
            fallthrough
        @unknown default:
            locationPermission = .notDetermined
        }
        return locationPermission
    }

    // Delegate method called when authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var locationPermissionValue: UserLocationPermission = .notDetermined
        switch manager.authorizationStatus {
        case .notDetermined:
            locationPermissionValue = .notDetermined
            authorizationStatus = .notDetermined
        case .restricted, .denied:
            locationPermissionValue = .restrictedOrDenied
            authorizationStatus = .denied
        case .authorizedWhenInUse:
            // Both cases .authorizeOnce and .authorizeWhenInUse
            // is not possible to differentiate between the two
            locationPermissionValue = .authorizeWhenInUse
            authorizationStatus = .authorizedWhenInUse
        case .authorizedAlways:
            // will never get called
            locationPermissionValue = .authorizeWhenInUse
            authorizationStatus = .authorizedWhenInUse
        case .authorized:
            locationPermissionValue = .authorizeWhenInUse
            authorizationStatus = .authorizedWhenInUse
        @unknown default:
            // Unknown location permission status
            locationPermissionValue = .notDetermined
            authorizationStatus = .notDetermined
        }
        
        permissionContinuation?.resume(returning: locationPermissionValue)
        permissionContinuation = nil
    }

    // Delegate method called with location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
        locationManager?.stopUpdatingLocation()
    }

    // Delegate method called if location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

struct LocationCoordinates: Codable, Hashable {
    let latitude: Double?
    let longitude: Double?
}

enum UserLocationPermission: Int, Codable {
    case notDetermined = 0
    case authorizeOnce = 1
    case authorizeWhenInUse = 2
    case restrictedOrDenied = 3

    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .authorizeOnce:
            return "Allow Once"
        case .authorizeWhenInUse:
            return "Allow While Using App"
        case .restrictedOrDenied:
            return "Don't Allow"
        }
    }
}

enum LocationError: LocalizedError {
    case notAuthorized
    case locationUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Location access is not authorized. Please enable it in Settings."
        case .locationUnavailable:
            return "Unable to retrieve your location."
        }
    }
}
