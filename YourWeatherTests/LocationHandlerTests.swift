//
//  LocationHandlerTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import CoreLocation
@testable import YourWeather

@MainActor
struct LocationHandlerTests {
    
    // MARK: Permission Tests
    
    @Test("Check location permission returns not determined when status is not determined")
    func checkPermissionNotDetermined() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .notDetermined
        handler.locationManager = mockManager
        
        let permission = handler.checkLocationPermission()
        #expect(permission == .notDetermined)
    }
    
    @Test("Check location permission returns restricted or denied when status is denied")
    func checkPermissionDenied() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .denied
        handler.locationManager = mockManager
        
        let permission = handler.checkLocationPermission()
        #expect(permission == .restrictedOrDenied)
    }
    
    @Test("Check location permission returns restricted or denied when status is restricted")
    func checkPermissionRestricted() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .restricted
        handler.locationManager = mockManager
        
        let permission = handler.checkLocationPermission()
        #expect(permission == .restrictedOrDenied)
    }
    
    @Test("Check location permission returns authorize when in use when status is authorized when in use")
    func checkPermissionAuthorizedWhenInUse() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .authorizedWhenInUse
        handler.locationManager = mockManager
        
        let permission = handler.checkLocationPermission()
        #expect(permission == .authorizeWhenInUse)
    }
    
    @Test("Check location permission returns authorize when in use when status is authorized always")
    func checkPermissionAuthorizedAlways() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .authorizedAlways
        handler.locationManager = mockManager
        
        let permission = handler.checkLocationPermission()
        #expect(permission == .authorizeWhenInUse)
    }
    
    // MARK: - Request Permission Tests
    
    @Test("Request permission returns current permission when already authorized")
    func requestPermissionAlreadyAuthorized() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .authorizedWhenInUse
        handler.locationManager = mockManager
        
        let permission = try await handler.requestPermission()
        
        #expect(mockManager.requestWhenInUseAuthorizationCalled == false)
        #expect(permission == .authorizeWhenInUse)
    }
    
    @Test("Request permission returns current permission when denied")
    func requestPermissionDenied() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .denied
        handler.locationManager = mockManager
        
        let permission = try await handler.requestPermission()
        
        #expect(mockManager.requestWhenInUseAuthorizationCalled == false)
        #expect(permission == .restrictedOrDenied)
    }
    
    
    @Test("Request location throws error when not authorized")
    func requestLocationNotAuthorized() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .denied
        handler.locationManager = mockManager
        
        do {
            _ = try await handler.requestLocation()
            Issue.record("Expected LocationError.notAuthorized to be thrown")
        } catch let error as LocationError {
            #expect(error == .notAuthorized)
        } catch {
            Issue.record("Expected LocationError.notAuthorized but got: \(error)")
        }
        
        #expect(mockManager.requestLocationCalled == false)
    }
    
    // MARK: Delegate Tests
    
    @Test("Location manager delegate updates authorization status to authorized when in use")
    func delegateAuthorizationChangeAuthorizedWhenInUse() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        handler.locationManager = mockManager
        mockManager.mockAuthorizationStatus = .authorizedWhenInUse
        
        
        handler.locationManagerDidChangeAuthorization(mockManager)
        
        #expect(handler.authorizationStatus == .authorizedWhenInUse)
    }
    
    @Test("Location manager delegate updates authorization status to denied")
    func delegateAuthorizationChangeDenied() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        handler.locationManager = mockManager
        mockManager.mockAuthorizationStatus = .denied
        
        handler.locationManagerDidChangeAuthorization(mockManager)
        
        #expect(handler.authorizationStatus == .denied)
    }
    
    @Test("Location manager delegate updates authorization status to not determined")
    func delegateAuthorizationChangeNotDetermined() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        handler.locationManager = mockManager
        mockManager.mockAuthorizationStatus = .notDetermined
        
        handler.locationManagerDidChangeAuthorization(mockManager)
        
        #expect(handler.authorizationStatus == .notDetermined)
    }
    
    @Test("Location manager delegate handles location update")
    func delegateLocationUpdate() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        handler.locationManager = mockManager
        
        let expectedLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        // Set up continuation manually for testing
        let location = try await withCheckedThrowingContinuation { continuation in
            handler.locationContinuation = continuation
            handler.locationManager(mockManager, didUpdateLocations: [expectedLocation])
        }
        
        #expect(location.coordinate.latitude == expectedLocation.coordinate.latitude)
        #expect(location.coordinate.longitude == expectedLocation.coordinate.longitude)
        #expect(handler.locationContinuation == nil, "Continuation should be cleared after use")
    }
    
    @Test("Location manager delegate stops updating location after receiving location")
    func delegateStopsUpdatingLocation() async throws {
        let handler = LocationHandler()
        let mockManager = MockCLLocationManager()
        handler.locationManager = mockManager
        let expectedLocation = CLLocation(latitude: 51.5074, longitude: -0.1278)
        handler.locationManager(mockManager, didUpdateLocations: [expectedLocation])
        
        #expect(mockManager.stopUpdatingLocationCalled == true)
    }
    
}

