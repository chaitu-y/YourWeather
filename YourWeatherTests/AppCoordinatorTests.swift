//
//  AppCoordinatorTests.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//
import Testing
import UIKit
@testable import YourWeather

@MainActor
struct AppCoordinatorTests {
    
    /*
     Note: Since we are not using storyboard and setting rootViewController to the window ourselves,
     we have to use UIWindow instance for testing even though its deprecated.
     */
    
    @Test func setupRootViewController() {
        let coordinator = AppCoordinator()
        coordinator.setupRootView(for: UIWindow())
        #expect(coordinator.navigationController.viewControllers.count == 1)
        #expect(coordinator.navigationController.viewControllers.first?.title == "Your Weather")
    }
    
    @Test func pushViewController() {
        let coordinator = AppCoordinator()
        coordinator.setupRootView(for: UIWindow())

        let newVC = UIViewController()
        coordinator.push(newVC, animated: false)

        #expect(coordinator.navigationController.viewControllers.count == 2)
    }

    @Test func popViewController() {
        let coordinator = AppCoordinator()
        coordinator.setupRootView(for: UIWindow())

        let newVC = UIViewController()
        coordinator.push(newVC, animated: false)
        coordinator.pop(animated: false)

        #expect(coordinator.navigationController.viewControllers.count == 1)
    }
    
    @Test func presentShowsModal() {
        let coordinator = AppCoordinator()
        coordinator.setupRootView(for: UIWindow())

        let modalVC = UIViewController()
        coordinator.present(modalVC, animated: false)

        #expect(coordinator.navigationController.presentedViewController === modalVC)
    }

    @Test func addAndRemoveChildCoordinator() {
        let parent = AppCoordinator()
        let child = AppCoordinator()

        parent.addChild(child)
        #expect(parent.childCoordinators.count == 1)

        parent.removeChild(child)
        #expect(parent.childCoordinators.isEmpty)
    }

    @Test func childCoordinatorsEmptyOnStart() {
        let coordinator = AppCoordinator()
        #expect(coordinator.childCoordinators.isEmpty)
    }
    
    
    
}
