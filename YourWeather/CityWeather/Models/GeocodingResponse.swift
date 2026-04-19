//
//  GeocodingResponse.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

struct GeocodingResponse: Decodable, Sendable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
