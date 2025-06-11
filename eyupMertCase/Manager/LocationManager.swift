//
//  LocationManager.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

protocol LocationManagerProtocol {
    var delegate: LocationManagerDelegate? { get set }
    func locationAuthorizationDidAsk()
    func startLocationManager()
    func stopLocationManager()
}

protocol LocationManagerDelegate: AnyObject {
    func navigateToAppSettings()
    func startTracking(coordinate: CLLocationCoordinate2D)
}

final class LocationManager: NSObject, LocationManagerProtocol {
    
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocationCoordinate2D?
    var trackedCoordinates: [CLLocationCoordinate2D] = []
    weak var delegate: LocationManagerDelegate?
    private var isTracking = false
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func startLocationManager() {
        guard !isTracking else { return }
        isTracking = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager() {
        guard isTracking else { return }
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    func didFocusUserLocation() {
        guard let location = locationManager.location else { return }
      //  delegate?.focusUserLocationDidUpdate(location: location)
    }
    
    func locationAuthorizationDidAsk() {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            delegate?.navigateToAppSettings()
            return
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationManager()
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLastLocation = locations.last?.coordinate else { return }
        trackedCoordinates.append(newLastLocation)
        let distance = approximatePathDistance()
        if distance >= 100 {
            delegate?.startTracking(coordinate: newLastLocation)
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
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationManager()
        default:
            locationManager.requestAlwaysAuthorization()
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
