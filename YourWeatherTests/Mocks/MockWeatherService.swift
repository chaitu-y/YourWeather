//
//  MockWeatherService.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
@testable import YourWeather

final class MockWeatherService: WeatherServiceProtocol {
    var weatherResult: Result<WeatherResponse, Error> = .failure(NSError(domain: "test", code: 0))
    var coordinatesResult: Result<[GeocodingResponse], Error> = .failure(NSError(domain: "test", code: 0))

    var fetchWeatherCallCount = 0
    var fetchCoordinatesCallCount = 0
    var lastWeatherLat: Double?
    var lastWeatherLon: Double?
    var lastCityName: String?

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        fetchWeatherCallCount += 1
        lastWeatherLat = latitude
        lastWeatherLon = longitude
        return try weatherResult.get()
    }

    func fetchCoordinates(for cityName: String) async throws -> [GeocodingResponse] {
        fetchCoordinatesCallCount += 1
        lastCityName = cityName
        return try coordinatesResult.get()
    }
}
