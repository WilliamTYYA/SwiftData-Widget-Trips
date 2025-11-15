//
//  PreviewSampleData.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/15/25.
//

import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, configurations: config)
        SampleData.createSampleData(into: container.mainContext)
        return container
    }
    
    static func createSampleData(into modelContext: ModelContext) {
        Task { @MainActor in
            let sampleTrips = Trip.previewTrips
            let sampleLA = LivingAccommodation.preview
            let sampleBLT = BucketListItem.previewBLTs
            let sampleData: [any PersistentModel] = sampleTrips + sampleLA + sampleBLT
            sampleData.forEach {
                modelContext.insert($0)
            }
            
            if let firstTrip = sampleTrips.first,
               let firstLA = sampleLA.first,
               let firstBLT = sampleBLT.first {
                firstTrip.livingAccommodation = firstLA
                firstTrip.bucketList.append(firstBLT)
            }
            
            if let lastTrip = sampleTrips.last,
               let lastBLT = sampleBLT.last {
                lastTrip.bucketList.append(lastBLT)
            }
            
            try? modelContext.save()
        }
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

@available(iOS 18.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}
