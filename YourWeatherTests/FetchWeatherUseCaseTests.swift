//
//  FetchWeatherUseCaseTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
@testable import YourWeather

@MainActor
struct FetchWeatherUseCaseTests {

    @Test func fetchWeatherReturnsResponse() async throws {
        let mockService = MockWeatherService()
        let expectedResponse = MockResponses.makeWeatherResponse(temp: 25.0)
        mockService.weatherResult = .success(expectedResponse)

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let result = try await useCase.fetchWeatherFor(latitude: 51.5, longitude: -0.12)

        #expect(result.main.temp == 25.0)
        #expect(mockService.fetchWeatherCallCount == 1)
        #expect(mockService.lastWeatherLat == 51.5)
        #expect(mockService.lastWeatherLon == -0.12)
    }

    @Test func fetchWeatherPropagatesError() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .failure(NSError(domain: "test", code: 404))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)

        do {
            _ = try await useCase.fetchWeatherFor(latitude: 0, longitude: 0)
            #expect(Bool(false), "Expected error to be thrown")
        } catch {
            #expect((error as NSError).code == 404)
        }
    }

    @Test func executeForCityFetchesWeatherAndSaves() async throws {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse(temp: 18.5))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)

        let city = MockResponses.makeCity(name: "Berlin", country: "DE", state: nil, lat: 52.52, lon: 13.40)
        let result = try await useCase.updateWeatherForCity(city)

        #expect(result.name == "Berlin")
        #expect(result.weather?.temperature == 18.5)
        #expect(mockRepository.saveCallCount == 1)
        #expect(mockRepository.savedCity?.name == "Berlin")
        #expect(mockRepository.savedCity?.weather?.temperature == 18.5)
    }

    @Test func getSavedCityReturnsRepositoryCity() throws {
        let mockRepository = MockCityRepository()
        let savedCity = MockResponses.makeCity(name: "Madrid", country: "ES", state: nil)
        mockRepository.savedCity = savedCity

        let useCase = FetchWeatherUseCase(service: MockWeatherService(), repository: mockRepository)
        let result = try useCase.getSavedCity()

        #expect(result?.name == "Madrid")
        #expect(mockRepository.getCallCount == 1)
    }

    @Test func getSavedCityReturnsNilWhenEmpty() throws {
        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: MockWeatherService(), repository: mockRepository)

        let result = try useCase.getSavedCity()

        #expect(result == nil)
    }

    @Test func fetchWeatherForSavedCityReturnsNilWhenNoSavedCity() async throws {
        let mockRepository = MockCityRepository()
        let mockService = MockWeatherService()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)

        let result = try await useCase.fetchWeatherForSavedCity()

        #expect(result == nil)
        #expect(mockService.fetchWeatherCallCount == 0)
    }

    @Test func fetchWeatherForSavedCityFetchesAndReturns() async throws {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse(temp: 22.0))

        let mockRepository = MockCityRepository()
        let savedCity = MockResponses.makeCity(name: "Rome", country: "IT", state: nil, lat: 41.90, lon: 12.50)
        mockRepository.savedCity = savedCity

        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let result = try await useCase.fetchWeatherForSavedCity()

        #expect(result?.name == "Rome")
        #expect(result?.weather?.temperature == 22.0)
        #expect(mockService.fetchWeatherCallCount == 1)
        #expect(mockRepository.saveCallCount == 1)
    }
}
