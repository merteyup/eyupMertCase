//
//  LocationManager.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

// MARK: - Protocols

protocol LocationManagerProtocol {
    var delegate: LocationManagerDelegate? { get set }
    func didLocationAuthAsked()
    func startLocationManager()
    func stopLocationManager()
    func didEnterBackground()
    func willEnterForeground()
}

protocol LocationManagerDelegate: AnyObject {
    func navigateToAppSettings()
    func startTracking(coordinate: CLLocationCoordinate2D)
    func trackingStateDidChange(isTracking: Bool)
}


final class LocationManager: NSObject, LocationManagerProtocol {
    
    // MARK: - Properties
    
    weak var delegate: LocationManagerDelegate?
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocationCoordinate2D?
    private var trackedLocations: [CLLocation] = []
    static let shared = LocationManager()
    
    private var isTracking = false {
        didSet {
            if oldValue != isTracking {
                delegate?.trackingStateDidChange(isTracking: isTracking)
            }
        }
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    func startLocationManager() {
        guard !isTracking else { return }
        isTracking = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = 2
        locationManager.startUpdatingLocation()
        lastLocation = locationManager.location?.coordinate
        guard let lastLocation else { return }
        delegate?.startTracking(coordinate: lastLocation)
    }
    
    func stopLocationManager() {
        guard isTracking else { return }
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        isTracking = false
    }
    
    func didLocationAuthAsked() {
        if isTracking {
            stopLocationManager()
        } else {
            switch locationManager.authorizationStatus {
            case .denied, .restricted:
                delegate?.navigateToAppSettings()
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                startLocationManager()
            default:
                break
            }
        }
    }
    
    func didEnterBackground() {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func willEnterForeground() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last,
              last.horizontalAccuracy < 20 else { return }
        trackedLocations.append(last)
        
        let distance = totalTraveledDistance()
        print("Toplam kat edilen mesafe: \(Int(distance)) metre")
        
        if distance >= 100 {
            delegate?.startTracking(coordinate: last.coordinate)
            trackedLocations.removeAll()
            lastLocation = last.coordinate
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
    
    // MARK: - Helpers
    
    func totalTraveledDistance() -> CLLocationDistance {
        guard trackedLocations.count > 1 else { return 0 }
        
        var totalDistance: CLLocationDistance = 0
        
        for i in 1..<trackedLocations.count {
            let previousLocation = trackedLocations[i - 1]
            let currentLocation = trackedLocations[i]
            let distance = previousLocation.distance(from: currentLocation)
            totalDistance += distance
        }
        
        return totalDistance
    }
}
