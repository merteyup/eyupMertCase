//
//  CLLocation+.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import CoreLocation

extension CLLocation {
    func getAddressFromLatLon(completion: @escaping ([CLPlacemark]?) -> Void) {
       let geocoder = CLGeocoder()
       geocoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) in
           if let error = error {
               print("Reverse geocode failed: \(error.localizedDescription)")
               return
           }
           completion(placemarks)
       })
   }
}

