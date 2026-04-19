//
//  FetchCityCoordinatesUseCaseTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
@testable import YourWeather

@MainActor
struct FetchCityCoordinatesUseCaseTests {

    @Test func fetchCoordinatesReturnsResults() async throws {
        let mockService = MockWeatherService()
        let expectedResults = [
            MockResponses.makeGeocodingResponse(name: "London", country: "GB"),
            MockResponses.makeGeocodingResponse(name: "London", country: "CA", state: "Ontario")
        ]
        mockService.coordinatesResult = .success(expectedResults)

        let useCase = FetchCityCoordinatesUseCase(service: mockService)
        let results = try await useCase.execute(cityName: "London")

        #expect(results.count == 2)
        #expect(results[0].name == "London")
        #expect(results[0].country == "GB")
        #expect(results[1].country == "CA")
        #expect(mockService.fetchCoordinatesCallCount == 1)
        #expect(mockService.lastCityName == "London")
    }

    @Test func fetchCoordinatesPropagatesError() async {
        let mockService = MockWeatherService()
        mockService.coordinatesResult = .failure(NSError(domain: "test", code: 500))

        let useCase = FetchCityCoordinatesUseCase(service: mockService)

        do {
            _ = try await useCase.execute(cityName: "Unknown")
            #expect(Bool(false), "Expected error to be thrown")
        } catch {
            #expect((error as NSError).code == 500)
        }
    }
}
