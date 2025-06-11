//
//  CLLocation+.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import CoreLocation

extension CLLocation {
    func getAddressFromLatLon(completion: @escaping (Result<[CLPlacemark]?, Error>) -> Void) {
       let geocoder = CLGeocoder()
       geocoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) in
           if let error {
               print("Reverse geocode failed: \(error.localizedDescription)")
               completion(.failure(error))
           } else {
               completion(.success(placemarks))
           }
       })
   }
}

