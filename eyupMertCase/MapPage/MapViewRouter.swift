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
        let visitStore = SwiftDataVisitStore(context: context)
        let viewModel = MapViewModel(locationManager: locationManager,
                                     visitStore: visitStore)
        let viewController = MapViewController()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        locationManager.delegate = viewModel
        return viewController
    }
}
