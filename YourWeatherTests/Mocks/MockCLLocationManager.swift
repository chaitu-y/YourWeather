//
//  MockCLLocationManager.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import CoreLocation
@testable import YourWeather

class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var requestWhenInUseAuthorizationCalled = false
    var requestLocationCalled = false
    var stopUpdatingLocationCalled = false
    
    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
        // Simulate authorization change
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.locationManagerDidChangeAuthorization?(self)
        }
    }
    
    override func requestLocation() {
        requestLocationCalled = true
    }
    
    override func stopUpdatingLocation() {
        stopUpdatingLocationCalled = true
    }
    
    // Helper method to simulate location updates
    func simulateLocationUpdate(_ location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.locationManager?(self, didUpdateLocations: [location])
        }
    }
    
    // Helper method to simulate location error
    func simulateLocationError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.locationManager?(self, didFailWithError: error)
        }
    }
    
    // Helper method to simulate authorization change
    func simulateAuthorizationChange(_ status: CLAuthorizationStatus) {
        mockAuthorizationStatus = status
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.locationManagerDidChangeAuthorization?(self)
        }
    }
}
