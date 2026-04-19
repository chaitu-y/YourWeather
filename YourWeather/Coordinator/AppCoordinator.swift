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
        
        let rootViewController = UIHostingController(rootView: CityView(viewModel: cityViewModel))
        rootViewController.title = "Weather"
        navigationController.setViewControllers([rootViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    
}
