//
//  VisitPoint.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import CoreLocation
import Foundation
import SwiftData

@Model
final class VisitPoint {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var createdAt: Date

    init(latitude: Double,
         longitude: Double,
         createdAt: Date = .now) {
        self.id = UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
}
