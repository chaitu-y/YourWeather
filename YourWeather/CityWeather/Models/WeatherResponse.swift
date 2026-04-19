//
//  WeatherResponse.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//
import Foundation

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
