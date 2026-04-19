//
//  WeatherService.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse
    func fetchCoordinates(for cityName: String) async throws -> [GeocodingResponse]
}

final class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    private let apiKey: String
    
    init(session: URLSession = .shared, apiKey: String = "8a51557140220a4e05f3a8e34c893522") {
        self.session = session
        self.apiKey = apiKey
    }

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
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

struct WeatherResponse: Decodable, Sendable {
    let coord: Coordinate
    let weather: [WeatherCondition]
    let main: MainWeather
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let rain: Rain?
    let dt: Int
    let sys: Sys?
    let timezone: Int
    let id: Int
    let name: String

    struct Coordinate: Decodable, Sendable {
        let lon: Double
        let lat: Double
    }

    struct WeatherCondition: Decodable, Sendable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }

    struct MainWeather: Decodable, Sendable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Wind: Decodable, Sendable {
        let speed: Double
        let deg: Int
        let gust: Double?
    }

    struct Clouds: Decodable, Sendable {
        let all: Int
    }
    
    struct Rain: Decodable, Sendable {
        let oneHour: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }

    struct Sys: Decodable, Sendable {
        let country: String?
        let sunrise: Int?
        let sunset: Int?
    }
}

struct GeocodingResponse: Decodable, Sendable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
