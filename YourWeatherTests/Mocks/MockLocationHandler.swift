//
//  MockLocationHandler.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
import CoreLocation
@testable import YourWeather

@MainActor
class MockLocationHandler: LocationHandler {
    
    // Control test behavior
    var permissionResult: Result<UserLocationPermission, Error>?
    var locationResult: Result<CLLocation, Error>?
    var mockIsPermissionDenied: Bool = false
    
    // Track calls
    var requestPermissionCallCount = 0
    var requestLocationCallCount = 0
    
    override init() {
        super.init()
    }
    
    override var isPermissionDenied: Bool {
        return mockIsPermissionDenied
    }
    
    override func requestPermission() async throws -> UserLocationPermission {
        requestPermissionCallCount += 1
        
        guard let result = permissionResult else {
            throw NSError(domain: "MockLocationHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "No permission result configured"])
        }
        
        switch result {
        case .success(let permission):
            return permission
        case .failure(let error):
            throw error
        }
    }
    
    override func requestLocation() async throws -> CLLocation {
        requestLocationCallCount += 1
        
        guard let result = locationResult else {
            throw NSError(domain: "MockLocationHandler", code: -1, userInfo: [NSLocalizedDescriptionKey: "No location result configured"])
        }
        
        switch result {
        case .success(let location):
            return location
        case .failure(let error):
            throw error
        }
    }
    
    // Helper to reset mock state
    func reset() {
        permissionResult = nil
        locationResult = nil
        mockIsPermissionDenied = false
        requestPermissionCallCount = 0
        requestLocationCallCount = 0
    }
}
