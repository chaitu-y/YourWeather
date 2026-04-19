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

    var onCitySelected: ((City) -> Void)?
    
    
}
