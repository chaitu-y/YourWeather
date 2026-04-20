//
//  CityViewModelTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
@testable import YourWeather

@MainActor //The City​View​Model class is marked with @​Observable, which makes it main actor isolated.
struct CityViewModelTests {
    @Test func initialStateHasNoCity() {
        let viewModel = CityViewModel()
        #expect(viewModel.selectedCity == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func selectCityFetchesWeather() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse(temp: 20.0, humidity: 55))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity()
        await viewModel.selectCity(city)

        #expect(viewModel.selectedCity?.name == "London")
        #expect(viewModel.selectedCity?.weather?.temperature == 20.0)
        #expect(viewModel.selectedCity?.weather?.humidity == 55)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func selectCitySetsErrorOnFailure() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .failure(NSError(domain: "test", code: 0))

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity()
        await viewModel.selectCity(city)

        #expect(viewModel.selectedCity == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func searchTappedCallsClosure() {
        let viewModel = CityViewModel()
        var called = false
        viewModel.onSearchTapped = { called = true }

        viewModel.searchTapped()

        #expect(called)
    }

    @Test func selectCitySavesToRepository() async {
        let mockService = MockWeatherService()
        mockService.weatherResult = .success(MockResponses.makeWeatherResponse())

        let mockRepository = MockCityRepository()
        let useCase = FetchWeatherUseCase(service: mockService, repository: mockRepository)
        let viewModel = CityViewModel(fetchWeatherUseCase: useCase)

        let city = MockResponses.makeCity(name: "Paris", country: "FR", state: nil)
        await viewModel.selectCity(city)

        #expect(mockRepository.saveCallCount == 1)
        #expect(mockRepository.savedCity?.name == "Paris")
        #expect(mockRepository.savedCity?.country == "FR")
    }
}
