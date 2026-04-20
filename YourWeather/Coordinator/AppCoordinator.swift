//
//  AppCoordinator.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//

import UIKit
import SwiftUI

@MainActor
class AppCoordinator: Coordinating {
    
    var navigationController =  UINavigationController()
    var childCoordinators: [any Coordinating] = []
    private let cityViewModel = CityViewModel()
    
    func setupRootView(for window: UIWindow) {
        cityViewModel.onSearchTapped = { [weak self] in
            self?.showCitySearch()
        }
        let rootViewController = CityViewController(viewModel: cityViewModel)
        rootViewController.title = "Weather"
        navigationController.setViewControllers([rootViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func showCitySearch() {
        let searchViewModel = CitySearchViewModel()
        searchViewModel.onCitySelected = { [weak self] city in
            self?.dismiss(animated: true)
            Task { @MainActor in
                await self?.cityViewModel.selectCity(city)
            }
        }

        let searchView = CitySearchView(viewModel: searchViewModel)
        let hostingController = UIHostingController(rootView: searchView)
        present(hostingController, animated: true)
    }
    
}
