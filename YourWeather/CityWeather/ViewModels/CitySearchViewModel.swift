//
//  CitySearchViewModel.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
import Observation

@Observable
class CitySearchViewModel  {
    
    var searchResults: [City] = []
    var isLoading = false
    var errorMessage: String?
    var searchQuery = "" {
        didSet { debouncedSearch() }
    }
    var onCitySelected: ((City) -> Void)?

    private let fetchCoordinatesUseCase: FetchCityCoordinatesUseCaseProtocol
    private var searchTask: Task<Void, Never>?

    init(fetchCoordinatesUseCase: FetchCityCoordinatesUseCaseProtocol = FetchCityCoordinatesUseCase()) {
        self.fetchCoordinatesUseCase = fetchCoordinatesUseCase
    }

    private func debouncedSearch() {
        searchTask?.cancel()
        let query = searchQuery
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            errorMessage = nil
            return
        }
        searchTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await searchCities()
        }
    }

    func searchCities() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let results = try await fetchCoordinatesUseCase.execute(cityName: query)
            searchResults = results.map { City(from: $0) }
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Failed to search cities. Please try again."
        }

        isLoading = false
    }

    func selectCity(_ city: City) {
        onCitySelected?(city)
    }
    
    
}
