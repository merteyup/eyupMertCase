//
//  LastLocationsStore.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import SwiftData

protocol LastLocationsStoreProtocol {
    func saveLastLocationVisit(latitude: Double, longitude: Double)
    func loadStoredLocations() -> [VisitPoint]
    func deleteVisitedLocations()
}

final class LastLocationsStore: LastLocationsStoreProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func saveLastLocationVisit(latitude: Double,
                               longitude: Double) {
        let point = VisitPoint(latitude: latitude,
                               longitude: longitude)
        context.insert(point)
        try? context.save()
    }
    
    func loadStoredLocations() -> [VisitPoint] {
        let descriptor = FetchDescriptor<VisitPoint>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func deleteVisitedLocations() {
        let all = loadStoredLocations()
        all.forEach { context.delete($0) }
        try? context.save()
    }
}
