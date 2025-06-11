//
//  MapViewModel.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation

protocol MapViewModelDelegate: AnyObject {
    func handleOutput(_ output: MapViewModelOutput)
}

enum MapViewModelOutput {
    case trackingStarted
    case trackingStopped
    case routeReset
    case centerMap
}

final class MapViewModel {
    weak var delegate: MapViewModelDelegate?

    private(set) var isTracking = false

    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            delegate?.handleOutput(.trackingStarted)
        } else {
            delegate?.handleOutput(.trackingStopped)
        }
    }

    func resetRoute() {
        delegate?.handleOutput(.routeReset)
    }
    
    func centerMap() {
        delegate?.handleOutput(.centerMap)
    }
}
