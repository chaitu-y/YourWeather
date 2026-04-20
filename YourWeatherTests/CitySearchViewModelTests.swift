//
//  CitySearchViewModelTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
@testable import YourWeather

@MainActor
struct CitySearchViewModelTests {

    @Test func initialStateIsEmpty() {
        let viewModel = CitySearchViewModel()
        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func searchCitiesReturnsResults() async {
        let mockService = MockWeatherService()
        mockService.coordinatesResult = .success([
            MockResponses.makeGeocodingResponse(name: "Paris", country: "FR", state: nil)
        ])

        let useCase = FetchCityCoordinatesUseCase(service: mockService)
        let viewModel = CitySearchViewModel(fetchCoordinatesUseCase: useCase)
        viewModel.searchQuery = "Paris"

        await viewModel.searchCities()

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.name == "Paris")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func searchCitiesWithEmptyQueryClearsResults() async {
        let mockService = MockWeatherService()
        let useCase = FetchCityCoordinatesUseCase(service: mockService)
        let viewModel = CitySearchViewModel(fetchCoordinatesUseCase: useCase)
        viewModel.searchQuery = "   "

        await viewModel.searchCities()

        #expect(viewModel.searchResults.isEmpty)
        #expect(mockService.fetchCoordinatesCallCount == 0)
    }

    @Test func searchCitiesSetsErrorOnFailure() async {
        let mockService = MockWeatherService()
        mockService.coordinatesResult = .failure(NSError(domain: "test", code: 0))

        let useCase = FetchCityCoordinatesUseCase(service: mockService)
        let viewModel = CitySearchViewModel(fetchCoordinatesUseCase: useCase)
        viewModel.searchQuery = "InvalidCity"

        await viewModel.searchCities()

        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func selectCityCallsClosure() {
        let viewModel = CitySearchViewModel()
        var selectedCity: City?
        viewModel.onCitySelected = { selectedCity = $0 }

        let city = MockResponses.makeCity(name: "Tokyo", country: "JP")
        viewModel.selectCity(city)

        #expect(selectedCity?.name == "Tokyo")
    }
}
