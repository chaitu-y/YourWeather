//
//  WeatherService.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse
    func fetchCoordinates(for cityName: String) async throws -> [GeocodingResponse]
}

final class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    
    private let fakeKey = "000000000000000000000000000"
    
    init(session: URLSession = .shared) {
        self.session = session
        self.apiKey = Bundle.main.object(forInfoDictionaryKey: "SETTING_KEY") as? String ?? fakeKey
    }

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    func fetchCoordinates(for cityName: String) async throws -> [GeocodingResponse] {
        var components = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct")!
        components.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode([GeocodingResponse].self, from: data)
    }
}


