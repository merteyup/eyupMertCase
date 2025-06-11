//
//  MapViewModel.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

final class MapViewModel: MapVMProtocol {
    
    var locationManager: (any LocationManagerProtocol)
    weak var delegate: (any MapViewDelegate)?
    
    init(locationManager: LocationManagerProtocol) {
        self.locationManager = locationManager
    }
   
    func fetchAdress(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        
        location.getAddressFromLatLon { [weak self] result in
            switch result {
            case .success(let placemarks):
                guard let placemark = placemarks?.first else { return }
                self?.delegate?.handleOutput(.selectedAddress(placemark.getAddress()))
            case .failure(let failure):
                self?.delegate?.handleOutput(.anyError(failure.localizedDescription))
            }
        }
    }
    
    func startTracking() {
        locationManager.locationAuthorizationDidAsk()
    }
    
    func resetRoute() {
        delegate?.handleOutput(.routeReset)
    }
}


extension MapViewModel: LocationManagerDelegate {
    
    func startTracking(coordinate: CLLocationCoordinate2D) {
        delegate?.handleOutput(.trackingStarted(coordinate))
    }
    
    func navigateToAppSettings() {
        delegate?.handleOutput(.navigateToAppSettings)
    }
    
}
