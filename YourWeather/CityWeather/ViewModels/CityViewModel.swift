//
//  CityViewModel.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
import Observation
import CoreLocation

@Observable
class CityViewModel {
    
    var selectedCity: City?
    var isLoading = false
    var errorMessage: String?
    var showAlert = false
    var onSearchTapped: (() -> Void)?
    
    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
    private let locationHandler: LocationHandler

    
    init (fetchWeatherUseCase: FetchWeatherUseCaseProtocol = FetchWeatherUseCase(),
          locationHandler: LocationHandler = LocationHandler()) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.locationHandler = locationHandler
        Task {
            await handleInitialLoad()
        }
    }
    
    func resetError() {
        errorMessage = nil
        showAlert = false
    }
    
    func handleInitialLoad() async {
        isLoading = true
        errorMessage = nil
        
        // load saved city if available
        do {
            if let cityWithWeather = try await fetchWeatherUseCase.fetchWeatherForSavedCity() {
                // load saved city's weather
                selectedCity = cityWithWeather
                isLoading = false
                return
            }
        } catch {
            // No saved city or error loading it, continue to location flow
        }
        
        if locationHandler.isPermissionDenied == false {
            await requestPermissionAndFetchWeatherForCurrentLocation()
        }
    }
}

// MARK: Current location

extension CityViewModel {
    func requestPermissionAndFetchWeatherForCurrentLocation() async {
        do {
            let permission = try await locationHandler.requestPermission()
            
            switch permission {
            case .authorizeWhenInUse, .authorizeOnce:
                // Permission granted. Get location and fetch weather
                await fetchWeatherForCurrentLocation()
                
            case .restrictedOrDenied:
                errorMessage = String(localized: "Location access denied. Please enable it in Settings.")
                showAlert = true
                isLoading = false
                
            case .notDetermined:
                isLoading = false
            }
        } catch {
            // Permission request failed
            errorMessage = String(localized: "Failed to request location permission.")
            showAlert = true
            isLoading = false
        }
    }
    
    func fetchWeatherForCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Request location
            let location = try await locationHandler.requestLocation()
            
            // Fetch weather for the location
            let cityWithWeather = try await fetchWeatherUseCase.fetchWeatherForCityAt(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            selectedCity = cityWithWeather
            errorMessage = nil
            
        } catch let error as LocationError {
            // Handle location-specific errors
            errorMessage = error.localizedDescription
            
        } catch {
            // Handle other errors
            errorMessage = String(localized: "Failed to fetch weather for your location.")
            showAlert = true
        }
        
        isLoading = false
    }
}

// MARK: City search
extension CityViewModel {
    func searchTapped() {
        onSearchTapped?()
    }
    
    func selectCity(_ city: City) async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch weather and save city
            let cityWithWeather = try await fetchWeatherUseCase.updateWeatherForCity(city)
            selectedCity = cityWithWeather
        } catch {
            errorMessage = String(localized: "Failed to fetch weather data.")
            showAlert = true
        }

        isLoading = false
    }
}
