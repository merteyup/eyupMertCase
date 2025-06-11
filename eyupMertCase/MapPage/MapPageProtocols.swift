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
}

/// View Model Output
enum MapVMOutput{
    case trackingStarted(_ location: CLLocationCoordinate2D)
    case anyError(String)
    case selectedAddress(_ address: String)
    case locationServicesDisabled
    case trackingStopped
    case routeReset
    case navigateToAppSettings
}
