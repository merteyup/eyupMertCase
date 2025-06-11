//
//  MapViewRouter.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

enum MapViewRouter {
    static func make() -> MapViewController {
        let locationManager = LocationManager()
        let viewModel = MapViewModel(locationManager: locationManager)
        let viewController = MapViewController()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        locationManager.delegate = viewModel
        
        return viewController
    }
}
