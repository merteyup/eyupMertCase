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
    private var fetchedAddresses: Set<String> = []
    
    init(locationManager: LocationManagerProtocol) {
        self.locationManager = locationManager
    }
   
    func fetchAdress(_ coordinate: CLLocationCoordinate2D) {
        let key = makeAddressKey(for: coordinate)
        guard shouldFetchAddress(for: key) else { return }
        
        reverseGeocode(coordinate: coordinate) { [weak self] result in
            self?.handleGeocodeResult(result, coordinate: coordinate)
        }
    }

    private func shouldFetchAddress(for key: String) -> Bool {
        guard !fetchedAddresses.contains(key) else { return false }
        fetchedAddresses.insert(key)
        return true
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D,
                                completion: @escaping (Result<[CLPlacemark]?, Error>) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        location.getAddressFromLatLon(completion: completion)
    }

    private func handleGeocodeResult(_ result: Result<[CLPlacemark]?, Error>,
                                     coordinate: CLLocationCoordinate2D) {
        switch result {
        case .success(let placemarks):
            guard let placemark = placemarks?.first else { return }
            delegate?.handleOutput(.selectedAddress(placemark.getAddress(), coordinate))
        case .failure(let error):
            delegate?.handleOutput(.anyError(error.localizedDescription))
        }
    }
    
    private func makeAddressKey(for coordinate: CLLocationCoordinate2D) -> String {
        "\(coordinate.latitude)-\(coordinate.longitude)"
    }
    
    func startTracking() {
        locationManager.didLocationAuthAsked()
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
