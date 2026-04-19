//
//  City.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

struct City: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let country: String
    let state: String?
    let lat: Double
    let lon: Double
    var weather: CityWeather?

    enum CodingKeys: String, CodingKey {
        case name, country, state, lat, lon
    }

    init(name: String, country: String, state: String?, lat: Double, lon: Double, weather: CityWeather? = nil) {
        self.id = UUID()
        self.name = name
        self.country = country
        self.state = state
        self.lat = lat
        self.lon = lon
        self.weather = weather
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lon = try container.decode(Double.self, forKey: .lon)
        self.weather = nil
    }

    var displayName: String {
        if let state {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
}

struct CityWeather: Sendable {
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int
    let description: String
    let icon: String
    let windSpeed: Double
    let cloudiness: Int
    let rain: Double?
    let visibility: Int?

    init(from response: WeatherResponse) {
        self.temperature = response.main.temp
        self.feelsLike = response.main.feelsLike
        self.tempMin = response.main.tempMin
        self.tempMax = response.main.tempMax
        self.humidity = response.main.humidity
        self.pressure = response.main.pressure
        self.description = response.weather.first?.description ?? ""
        self.icon = response.weather.first?.icon ?? ""
        self.windSpeed = response.wind?.speed ?? 0
        self.cloudiness = response.clouds?.all ?? 0
        self.rain = response.rain?.oneHour
        self.visibility = response.visibility
    }
}

extension City {
    init(from geo: GeocodingResponse) {
        self.init(name: geo.name, country: geo.country, state: geo.state, lat: geo.lat, lon: geo.lon)
    }
}
