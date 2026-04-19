//
//  MockCityRepository.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
@testable import YourWeather

final class MockCityRepository: CityRepositoryProtocol {
    var savedCity: City?
    var shouldThrowError = false
    var saveCallCount = 0
    var getCallCount = 0
    var clearCallCount = 0
    
    func saveCity(_ city: City) throws {
        saveCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockCityRepository", code: 1, userInfo: nil)
        }
        savedCity = city
    }
    
    func getSavedCity() throws -> City? {
        getCallCount += 1
        if shouldThrowError {
            throw NSError(domain: "MockCityRepository", code: 2, userInfo: nil)
        }
        return savedCity
    }
    
    func clearSavedCity() {
        clearCallCount += 1
        savedCity = nil
    }
}
