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
    func fetchAdress(_ coordinate: CLLocationCoordinate2D)
}

/// View Model Output
enum MapVMOutput{
    case currentLocation(_ location: CLLocationCoordinate2D)
    case anyError(String)
    case selectedAddress(_ address: String)
    case locationServicesDisabled
    case trackingStarted
    case trackingStopped
    case routeReset
    case centerMap
}
