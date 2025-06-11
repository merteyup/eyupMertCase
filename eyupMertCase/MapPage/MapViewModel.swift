//
//  MapViewModel.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

final class MapViewModel: MapVMProtocol {
    
    weak var delegate: (any MapViewDelegate)?
    private(set) var isTracking = false
   
    func fetchAdress(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        
        location.getAddressFromLatLon { placemarks in
            <#code#>
        }
    }
    
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
