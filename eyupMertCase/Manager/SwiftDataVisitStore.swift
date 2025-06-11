//
//  SwiftDataVisitStore.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import Foundation
import SwiftData

protocol VisitStoreProtocol {
    func saveVisitPoint(latitude: Double, longitude: Double)
    func fetchAllVisitPoints() -> [VisitPoint]
    func deleteAllVisitPoints()
}

final class SwiftDataVisitStore: VisitStoreProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func saveVisitPoint(latitude: Double,
                        longitude: Double) {
        let point = VisitPoint(latitude: latitude,
                               longitude: longitude)
        context.insert(point)
        try? context.save()
    }

    func fetchAllVisitPoints() -> [VisitPoint] {
        let descriptor = FetchDescriptor<VisitPoint>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func deleteAllVisitPoints() {
        let all = fetchAllVisitPoints()
        all.forEach { context.delete($0) }
        try? context.save()
    }
}
