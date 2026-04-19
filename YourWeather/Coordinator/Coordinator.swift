//
//  Coordinator.swift
//  YourWeather
//
//  Created by chaitu on 4/19/26.
//
import UIKit
import SwiftUI

protocol Coordinating: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinating] { get set }

    func push(_ viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

extension Coordinating {
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    func addChild(_ coordinator: Coordinating) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinating) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
