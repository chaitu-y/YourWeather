//
//  CityViewModel.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import Foundation
import Observation

@Observable
class CityViewModel {
    
    var selectedCity: City?
    var isLoading = false
    var errorMessage: String?
    
}
