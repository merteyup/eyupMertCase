//
//  MapViewModel.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import CoreLocation.CLLocation
import Foundation
import SwiftData


final class MapViewModel: MapVMProtocol {
    
    // MARK: - Properties
    
    var locationManager: (any LocationManagerProtocol)
    weak var delegate: (any MapViewDelegate)?
    private let lastLocationsStore: LastLocationsStoreProtocol
    private var fetchedAddresses: Set<String> = []
    
    // MARK: - Init
    
    init(locationManager: LocationManagerProtocol,
         lastLocationsStore: LastLocationsStoreProtocol) {
        self.locationManager = locationManager
        self.lastLocationsStore = lastLocationsStore
    }
    
    // MARK: - Public Methods
    
    func startTracking() {
        locationManager.didLocationAuthAsked()
    }
    
    func saveLocation(_ coordinate: CLLocationCoordinate2D) {
        lastLocationsStore.saveLastLocationVisit(latitude: coordinate.latitude,
                                                 longitude: coordinate.longitude)
    }
    
    func loadStoredLocations() -> [VisitPoint] {
        lastLocationsStore.loadStoredLocations()
    }
    
    func clearVisitPoints() {
        lastLocationsStore.deleteVisitedLocations()
        delegate?.handleOutput(.routeReset)
    }
    
    func fetchAdress(_ coordinate: CLLocationCoordinate2D) {
        let key = makeAddressKey(for: coordinate)
        guard shouldFetchAddress(for: key) else { return }
        
        reverseGeocode(coordinate: coordinate) { [weak self] result in
            self?.handleGeocodeResult(result, coordinate: coordinate)
        }
    }
    
    // MARK: - Private Helpers
    
    private func shouldFetchAddress(for key: String) -> Bool {
        guard !fetchedAddresses.contains(key) else { return false }
        fetchedAddresses.insert(key)
        return true
    }
    
    private func reverseGeocode(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping (
            Result<[CLPlacemark]?, Error>
        ) -> Void) {
            let location = CLLocation(latitude: coordinate.latitude,
                                      longitude: coordinate.longitude)
            location.getAddressFromLatLon(completion: completion)
        }
    
    private func handleGeocodeResult(_ result: Result<[CLPlacemark]?, Error>,
                                     coordinate: CLLocationCoordinate2D) {
        switch result {
        case .success(let placemarks):
            guard let placemark = placemarks?.first else { return }
            delegate?.handleOutput(.selectedAddress(placemark.getAddress(),
                                                    coordinate))
        case .failure(let error):
            delegate?.handleOutput(.anyError(error.localizedDescription))
        }
    }
    
    private func makeAddressKey(for coordinate: CLLocationCoordinate2D) -> String {
        "\(coordinate.latitude)-\(coordinate.longitude)"
    }
}

// MARK: - LocationManagerDelegate

extension MapViewModel: LocationManagerDelegate {
    
    func trackingStateDidChange(isTracking: Bool) {
        delegate?.handleOutput(.trackingStatusChanged(isTracking))
    }
    
    func startTracking(coordinate: CLLocationCoordinate2D) {
        delegate?.handleOutput(.trackingStarted(coordinate))
        saveLocation(coordinate)
    }
    
    func navigateToAppSettings() {
        delegate?.handleOutput(.navigateToAppSettings)
    }
}
