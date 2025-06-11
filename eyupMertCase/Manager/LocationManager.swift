//
//  LocationManager.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

final class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D?
    var trackedCoordinates: [CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
    }
    
    func start() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stop() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLastLocation = locations.last?.coordinate else { return }
        trackedCoordinates.append(newLastLocation)
        let distance = approximatePathDistance()
        if distance >= 100 {
            trackedCoordinates.removeAll()
            lastLocation = newLastLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        guard let error = error as? CLError else { return }
        let code = error.code
        switch code {
        case .network:
            print("Error Code: network")
        case .locationUnknown:
            print("Error Code: location unknown")
        default:
            print(error.localizedDescription)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startMonitoringSignificantLocationChanges()
        default:
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func approximatePathDistance() -> CLLocationDistance {
        guard trackedCoordinates.count > 1 else { return 0 }
        var total: CLLocationDistance = 0
        for i in 1..<trackedCoordinates.count {
            let loc1 = CLLocation(latitude: trackedCoordinates[i-1].latitude, longitude: trackedCoordinates[i-1].longitude)
            let loc2 = CLLocation(latitude: trackedCoordinates[i].latitude, longitude: trackedCoordinates[i].longitude)
            total += loc1.distance(from: loc2)
        }
        return total
    }
}
