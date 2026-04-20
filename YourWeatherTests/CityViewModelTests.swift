//
//  CityViewModelTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
import CoreLocation
@testable import YourWeather

@MainActor //The City​View​Model class is marked with @​Observable, which makes it main actor isolated.
struct CityViewModelTests {
        
    @Test func initialStateHasNoCity() {
        let viewModel = CityViewModel()
        #expect(viewModel.selectedCity == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func selectCityFetchesWeather() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse(temp: 20.0, humidity: 55))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity()
        await viewModel.selectCity(city)

        #expect(viewModel.selectedCity?.name == "London")
        #expect(viewModel.selectedCity?.weather?.temperature == 20.0)
        #expect(viewModel.selectedCity?.weather?.humidity == 55)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func selectCitySetsErrorOnFailure() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .failure(NSError(domain: "test", code: 0))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity()
        await viewModel.selectCity(city)

        #expect(viewModel.selectedCity == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func searchTappedCallsClosure() {
        let viewModel = CityViewModel()
        var called = false
        viewModel.onSearchTapped = { called = true }

        viewModel.searchTapped()

        #expect(called)
    }

    @Test func selectCitySavesToRepository() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse())

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity(name: "Paris", country: "FR", state: nil)
        await viewModel.selectCity(city)

        #expect(mockRepository.saveCallCount == 1)
        #expect(mockRepository.savedCity?.name == "Paris")
        #expect(mockRepository.savedCity?.country == "FR")
    }
    
    @Test func selectCitySetsShowAlertOnError() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .failure(NSError(domain: "test", code: 0))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity()
        await viewModel.selectCity(city)

        #expect(viewModel.showAlert == true)
        #expect(viewModel.errorMessage != nil)
    }
    
    
    @Test func resetErrorClearsErrorState() {
        let mockService = MockWeatherService()
        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)
        
        // Set error state
        viewModel.errorMessage = "Test error"
        viewModel.showAlert = true
        
        // Reset error
        viewModel.resetError()
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showAlert == false)
    }
    
    
    @Test func handleInitialLoadWithSavedCity() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse(temp: 25.0))
        
        let mockRepository = MockCityRepository()
        let savedCity = MockResponses.makeCity(name: "Berlin", country: "DE")
        mockRepository.savedCity = savedCity
        
        let mockLocationHandler = MockLocationHandler()
        
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(
            fetchWeatherUseCase: useCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.handleInitialLoad()
        
        // Should load the saved city
        #expect(mockRepository.getCallCount == 1)
        #expect(viewModel.selectedCity?.name == "Berlin")
        #expect(viewModel.selectedCity?.weather?.temperature == 25.0)
        
        // Should NOT request location permission
        #expect(mockLocationHandler.requestPermissionCallCount == 0)
    }
    
    @Test func handleInitialLoadWithoutSavedCityRequestsLocation() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse())
        mockService.coordinatesResult = .success([
            MockResponses.makeGeocodingResponse(name: "Current Location", country: "US")
        ])
        
        let mockRepository = MockCityRepository()
        mockRepository.savedCity = nil // No saved city
        
        let mockLocationHandler = MockLocationHandler()
        mockLocationHandler.permissionResult = .success(.authorizeWhenInUse)
        mockLocationHandler.locationResult = .success(CLLocation(latitude: 40.7128, longitude: -74.0060))
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.handleInitialLoad()
        
        // Should check for saved city
        #expect(mockRepository.getCallCount == 1)
        
        // Should request location permission
        #expect(mockLocationHandler.requestPermissionCallCount == 1)
    }
        
    @Test func requestPermissionAndFetchWeatherWhenGranted() async {
        let mockService = MockWeatherService()
        // The weather response name is what will be used as the city name
        let weatherResponse = WeatherResponse(
            coord: .init(lon: -74.0060, lat: 40.7128),
            weather: [.init(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: .init(temp: 22.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 25.0, pressure: 1013, humidity: 60),
            visibility: 10000,
            wind: .init(speed: 3.5, deg: 180, gust: nil),
            clouds: .init(all: 10),
            rain: .init(oneHour: 0.0),
            dt: 1726660758,
            sys: .init(country: "US", sunrise: 1726636384, sunset: 1726680975),
            timezone: -18000,
            id: 5128581,
            name: "New York"
        )
        mockService.weatherResult = .success(weatherResponse)
        
        let mockRepository = MockCityRepository()
        
        let mockLocationHandler = MockLocationHandler()
        mockLocationHandler.permissionResult = .success(.authorizeWhenInUse)
        mockLocationHandler.locationResult = .success(CLLocation(latitude: 40.7128, longitude: -74.0060))
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.requestPermissionAndFetchWeatherForCurrentLocation()
        
        // Should request permission
        #expect(mockLocationHandler.requestPermissionCallCount == 1)
        
        // Should request location
        #expect(mockLocationHandler.requestLocationCallCount == 1)
        
        // Should fetch weather
        #expect(viewModel.selectedCity?.name == "New York")
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func requestPermissionShowsErrorWhenDenied() async {
        let mockService = MockWeatherService()
        let mockRepository = MockCityRepository()
        
        let mockLocationHandler = MockLocationHandler()
        mockLocationHandler.permissionResult = .success(.restrictedOrDenied)
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.requestPermissionAndFetchWeatherForCurrentLocation()
        
        // Should request permission
        #expect(mockLocationHandler.requestPermissionCallCount == 1)
        
        // Should NOT request location
        #expect(mockLocationHandler.requestLocationCallCount == 0)
        
        // Should show error
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.showAlert == true)
    }
    
    
    @Test func fetchWeatherForCurrentLocationSuccess() async {
        let mockService = MockWeatherService()
        // The weather response name is what will be used as the city name
        let weatherResponse = WeatherResponse(
            coord: .init(lon: -122.4194, lat: 37.7749),
            weather: [.init(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: .init(temp: 22.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 25.0, pressure: 1013, humidity: 60),
            visibility: 10000,
            wind: .init(speed: 3.5, deg: 180, gust: nil),
            clouds: .init(all: 10),
            rain: .init(oneHour: 0.0),
            dt: 1726660758,
            sys: .init(country: "US", sunrise: 1726636384, sunset: 1726680975),
            timezone: -18000,
            id: 5128581,
            name: "New York"
        )
        mockService.weatherResult = .success(weatherResponse)
        
        let mockRepository = MockCityRepository()
        
        let mockLocationHandler = MockLocationHandler()
        mockLocationHandler.locationResult = .success(CLLocation(latitude: 37.7749, longitude: -122.4194))
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.fetchWeatherForCurrentLocation()
        
        // Should request location
        #expect(mockLocationHandler.requestLocationCallCount == 1)
        // Should fetch weather for location
        #expect(viewModel.selectedCity?.name == "New York")
        #expect(viewModel.selectedCity?.weather?.temperature == 22.0)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func fetchWeatherForCurrentLocationHandlesLocationError() async {
        let mockService = MockWeatherService()
        let mockRepository = MockCityRepository()
        
        let mockLocationHandler = MockLocationHandler()
        let locationError = NSError(domain: "LocationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location unavailable"])
        mockLocationHandler.locationResult = .failure(locationError)
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.fetchWeatherForCurrentLocation()
        
        // Should show error
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.showAlert == true)
        #expect(viewModel.selectedCity == nil)
    }
    
    @Test func fetchWeatherForCurrentLocationHandlesWeatherFetchError() async {
        let mockService = MockWeatherService()
        mockService.coordinatesResult = .failure(NSError(domain: "WeatherError", code: -1))
        
        let mockRepository = MockCityRepository()
        
        let mockLocationHandler = MockLocationHandler()
        mockLocationHandler.locationResult = .success(CLLocation(latitude: 40.7128, longitude: -74.0060))
        
        let fetchWeatherUseCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        
        let viewModel = CityViewModel(
            fetchWeatherUseCase: fetchWeatherUseCase,
            locationHandler: mockLocationHandler
        )
        
        await viewModel.fetchWeatherForCurrentLocation()
        
        // Should show error
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.showAlert == true)
    }
}
