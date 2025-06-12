//
//  LocationWakeUpHandler.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 12.06.2025.
//


final class LocationWakeUpHandler {
    
    static let shared = LocationWakeUpHandler()
    
    private init() {}
    
    func handleWakeUpFromLocationLaunch() {
        print("Application woke up with location from background.")
    }
}
