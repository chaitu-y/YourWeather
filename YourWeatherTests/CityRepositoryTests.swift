//
//  CityRepositoryTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Testing
import Foundation
@testable import YourWeather

@MainActor
struct CityRepositoryTests {

    private func makeTestDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }

    @Test func saveCityPersistsToUserDefaults() throws {
        let defaults = makeTestDefaults()
        let repository = CityRepository(userDefaults: defaults)
        
        let city = MockResponses.makeCity(name: "London", country: "GB", state: nil, lat: 51.5, lon: -0.12)
        
        try repository.saveCity(city)
        
        let savedData = defaults.data(forKey: "savedCity")
        #expect(savedData != nil)
        
        let decodedCity = try JSONDecoder().decode(City.self, from: savedData!)
        #expect(decodedCity.name == "London")
        #expect(decodedCity.country == "GB")
        #expect(decodedCity.lat == 51.5)
        #expect(decodedCity.lon == -0.12)
    }

    @Test func getSavedCityReturnsPersistedCity() throws {
        let defaults = makeTestDefaults()
        let repository = CityRepository(userDefaults: defaults)
        
        let city = MockResponses.makeCity(name: "Paris", country: "FR", state: nil)
        let data = try JSONEncoder().encode(city)
        defaults.set(data, forKey: "savedCity")
        
        let result = try repository.getSavedCity()
        
        #expect(result?.name == "Paris")
        #expect(result?.country == "FR")
    }

    @Test func getSavedCityReturnsNilWhenEmpty() throws {
        let defaults = makeTestDefaults()
        let repository = CityRepository(userDefaults: defaults)
        
        let result = try repository.getSavedCity()
        
        #expect(result == nil)
    }

    @Test func clearSavedCityRemovesData() throws {
        let defaults = makeTestDefaults()
        let repository = CityRepository(userDefaults: defaults)
        
        let city = MockResponses.makeCity()
        try repository.saveCity(city)
        
        #expect(try repository.getSavedCity() != nil)
        
        repository.clearSavedCity()
        
        #expect(try repository.getSavedCity() == nil)
        #expect(defaults.data(forKey: "savedCity") == nil)
    }

    @Test func saveCityOverwritesPreviousCity() throws {
        let defaults = makeTestDefaults()
        let repository = CityRepository(userDefaults: defaults)
        
        let city1 = MockResponses.makeCity(name: "New York", country: "US", state: "NY")
        try repository.saveCity(city1)
        
        let city2 = MockResponses.makeCity(name: "Los Angeles", country: "US", state: "CA")
        try repository.saveCity(city2)
        
        let result = try repository.getSavedCity()
        
        #expect(result?.name == "Los Angeles")
        #expect(result?.state == "CA")
    }
}
