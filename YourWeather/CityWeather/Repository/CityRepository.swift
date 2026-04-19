//
//  CityRepository.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation

protocol CityRepositoryProtocol: Sendable {
    func saveCity(_ city: City) throws
    func getSavedCity() throws -> City?
    func clearSavedCity()
}

final class CityRepository: CityRepositoryProtocol {
    private let userDefaults: UserDefaults
    private static let savedCityKey = "savedCity"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveCity(_ city: City) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(city)
        userDefaults.set(data, forKey: Self.savedCityKey)
    }
    
    func getSavedCity() throws -> City? {
        guard let data = userDefaults.data(forKey: Self.savedCityKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(City.self, from: data)
    }
    
    func clearSavedCity() {
        userDefaults.removeObject(forKey: Self.savedCityKey)
    }
}
