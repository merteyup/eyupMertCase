//
//  CLPlacemark+GetAddress.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import CoreLocation.CLPlacemark

extension CLPlacemark {
    func getAddress() -> String {
        var addressParts: [String] = []
        
        if let subThoroughfare = self.subThoroughfare {
            addressParts.append(subThoroughfare)
        }
        
        if let thoroughfare = self.thoroughfare {
            addressParts.append(thoroughfare)
        }
        
        if let locality = self.locality {
            addressParts.append(locality)
        }
        
        if let administrativeArea = self.administrativeArea {
            addressParts.append(administrativeArea)
        }
        
        if let postalCode = self.postalCode {
            addressParts.append(postalCode)
        }
        
        if let country = self.country {
            addressParts.append(country)
        }
        
        return addressParts.joined(separator: ", ")
    }
}
