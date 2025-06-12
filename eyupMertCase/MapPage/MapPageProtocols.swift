//
//  MapPageProtocols.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import CoreLocation.CLLocation

///  View Delegate
protocol MapViewDelegate: AnyObject {
    func handleOutput(_ output: MapVMOutput)
}

///  View Model Protocol
protocol MapVMProtocol: AnyObject {
    var delegate: MapViewDelegate? { get set }
    var locationManager: LocationManagerProtocol { get }
    func fetchAdress(_ coordinate: CLLocationCoordinate2D)
    func startTracking()
    func loadStoredLocations() -> [VisitPoint]
    func clearVisitPoints()
}

/// View Model Output
enum MapVMOutput{
    case trackingStarted(_ location: CLLocationCoordinate2D)
    case anyError(String)
    case selectedAddress(String, CLLocationCoordinate2D)
    case routeReset
    case navigateToAppSettings
    case trackingStatusChanged(Bool)
}
