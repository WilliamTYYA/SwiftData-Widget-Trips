//
//  DataModel.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/12/25.
//

import Foundation
import SwiftData

actor DataModel {
    struct TransactionAuthor {
        static let widget = "widget"
    }
    
    static let shared = DataModel()
    
    static let container: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: Trip.self, PersonalTrip.self, BusinessTrip.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        return modelContainer
    }()
    
    nonisolated var container: ModelContainer {
        Self.container
    }
}
