//
//  FetchCityCoordinatesUseCase.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

protocol FetchCityCoordinatesUseCaseProtocol: Sendable {
    func execute(cityName: String) async throws -> [GeocodingResponse]
}

final class FetchCityCoordinatesUseCase: FetchCityCoordinatesUseCaseProtocol {
    private let service: WeatherServiceProtocol

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }

    func execute(cityName: String) async throws -> [GeocodingResponse] {
        try await service.fetchCoordinates(for: cityName)
    }
}
