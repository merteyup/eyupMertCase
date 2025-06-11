//
//  MapViewRouter.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

enum MapViewRouter {
    static func make(with viewModel: MapViewModel? = nil) -> MapViewController {
        let locationManager = LocationManager.shared
        let vm = viewModel ?? MapViewModel(locationManager: locationManager)
        let viewController = MapViewController()
        viewController.viewModel = vm
        vm.delegate = viewController
        locationManager.delegate = vm
        return viewController
    }
}
