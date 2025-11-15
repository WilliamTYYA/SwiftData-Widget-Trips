//
//  ContentView.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    enum Segment: String, CaseIterable {
        case all = "All"
        case personal = "Personal"
        case business = "Business"
    }

    var body: some View {
        Text("Hello World")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
