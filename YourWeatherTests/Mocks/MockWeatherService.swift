//
//  MockWeatherService.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
@testable import YourWeather

struct MockResponses {
    
    static func makeWeatherResponse(
        temp: Double = 22.0,
        feelsLike: Double = 20.0,
        tempMin: Double = 18.0,
        tempMax: Double = 25.0,
        humidity: Int = 60,
        pressure: Int = 1013,
        description: String = "Partly Cloudy",
        icon: String = "10d",
        windSpeed: Double = 3.5,
        cloudiness: Int = 10,
        rain: Double = 0.0
    ) -> WeatherResponse {
        WeatherResponse(
            coord: .init(lon: 0, lat: 0),
            weather: [.init(id: 800, main: "Sunny", description: description, icon: icon)],
            main: .init(temp: temp, feelsLike: feelsLike, tempMin: tempMin, tempMax: tempMax, pressure: pressure, humidity: humidity),
            visibility: 10000,
            wind: .init(speed: windSpeed, deg: 180, gust: nil),
            clouds: .init(all: cloudiness), rain: .init(oneHour: rain),
            dt: 1726660758,
            sys: .init(country: "US", sunrise: 1726636384, sunset: 1726680975),
            timezone: -28800,
            id: 12345,
            name: "Test City"
        )
    }

    static func makeGeocodingResponse(
        name: String = "London",
        lat: Double = 51.5074,
        lon: Double = -0.1278,
        country: String = "GB",
        state: String? = "England"
    ) -> GeocodingResponse {
        GeocodingResponse(name: name, lat: lat, lon: lon, country: country, state: state)
    }

    static func makeCity(
        name: String = "London",
        country: String = "GB",
        state: String? = "England",
        lat: Double = 51.5074,
        lon: Double = -0.1278
    ) -> City {
        City(name: name, country: country, state: state, lat: lat, lon: lon)
    }
}
