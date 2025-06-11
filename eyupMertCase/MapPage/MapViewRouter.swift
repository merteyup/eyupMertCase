//
//  MapViewRouter.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import SwiftData

enum MapViewRouter {
    static func make(context: ModelContext) -> MapViewController {
        let locationManager = LocationManager.shared
        let lastLocationsStore = LastLocationsStore(context: context)
        let viewModel = MapViewModel(locationManager: locationManager,
                                     lastLocationsStore: lastLocationsStore)
        let viewController = MapViewController()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        locationManager.delegate = viewModel
        return viewController
    }
}
