//
//  CitySearchView.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import SwiftUI

struct CitySearchView: View {
    
    @Bindable var viewModel: CitySearchViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Search Failed",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchQuery)
                } else if viewModel.searchResults.isEmpty {
                    ContentUnavailableView(
                        "Search for a US City",
                        systemImage: "magnifyingglass",
                        description: Text("Type a city name to get started.")
                    )
                } else {
                    List(viewModel.searchResults) { city in
                        Button {
                            viewModel.selectCity(city)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.headline)
                                Text(city.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search cities")
            .navigationTitle("Search Cities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
