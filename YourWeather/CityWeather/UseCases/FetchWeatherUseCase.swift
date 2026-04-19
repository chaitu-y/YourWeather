
//
//  FetchWeatherUseCase.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

protocol FetchWeatherUseCaseProtocol {
    func fetchWeatherFor(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func updateWeatherForCity(_ city: City) async throws -> City
    func fetchWeatherForCityAt(latitude: Double, longitude: Double) async throws -> City
    func getSavedCity() throws -> City?
    func fetchWeatherForSavedCity() async throws -> City?
}

final class FetchWeatherUseCase: FetchWeatherUseCaseProtocol {
    private let service: WeatherServiceProtocol
    private let repository: CityRepositoryProtocol

    init(
        service: WeatherServiceProtocol = WeatherService(),
        repository: CityRepositoryProtocol = CityRepository()
    ) {
        self.service = service
        self.repository = repository
    }

    func fetchWeatherFor(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        try await service.fetchWeather(latitude: latitude, longitude: longitude)
    }
    
    func updateWeatherForCity(_ city: City) async throws -> City {
        // Fetch weather data
        let weatherResponse = try await service.fetchWeather(latitude: city.lat, longitude: city.lon)
        
        // Create updated city with weather
        var updatedCity = city
        updatedCity.weather = CityWeather(from: weatherResponse)
        
        // Save to repository
        try repository.saveCity(updatedCity)
        
        return updatedCity
    }
    
    func getSavedCity() throws -> City? {
        try repository.getSavedCity()
    }
    
    func fetchWeatherForSavedCity() async throws -> City? {
        guard let savedCity = try repository.getSavedCity() else {
            return nil
        }
        
        return try await updateWeatherForCity(savedCity)
    }
    
    func fetchWeatherForCityAt(latitude: Double, longitude: Double) async throws -> City {
        // Fetch weather data using coordinates
        let weatherResponse = try await service.fetchWeather(latitude: latitude, longitude: longitude)
        
        // Create city with weather response
        let city = City(
            name: weatherResponse.name,
            country: weatherResponse.sys?.country ?? "Unknown",
            state: nil,
            lat: weatherResponse.coord.lat,
            lon: weatherResponse.coord.lon,
            weather: CityWeather(from: weatherResponse)
        )
        
        return city
    }
}
