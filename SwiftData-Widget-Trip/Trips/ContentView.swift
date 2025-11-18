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
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: Trip?
    @State private var unreadTripIdentifiers: [PersistentIdentifier] = []
    @State private var tripCount: Int = 0
    @State private var selectedSegement: Segment = .all
    @State private var newTripSegment: Segment = .all
    @State private var searchText: String = ""
    @State private var showAddTrip = false

    var body: some View {
        NavigationSplitView {
            TripListView(
                selection: $selection,
                segment: selectedSegement,
                unreadTripIdentifiers: unreadTripIdentifiers,
                tripCount: $tripCount,
                searchText: searchText)
            .toolbar {
                toolbarItems
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            #endif
            
            #if os(macOS)
            tripSegmentPicker
                .padding(.bottom)
            #endif
        } detail: {
            if let selection = selection {
                NavigationStack {
                    TripDetailView(trip: selection)
                }
            } else {
                ContentUnavailableView("Select a Trip", systemImage: "car.circle")
            }
        }
        .task {
            unreadTripIdentifiers = await DataModel.shared.unreadTripIdentifiersInUserDefaults
        }
        #if os(macOS)
        .searchable(text: $searchText, placement: .sidebar)
        #else
        .searchable(text: $searchText)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        #endif
        .sheet(isPresented: $showAddTrip) {
            NavigationStack {
                AddTripView(newTripSegment: newTripSegment)
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: selection) { _,  newValue in
            if let newSelection = newValue {
                if let index = unreadTripIdentifiers.firstIndex(where: {
                    $0 == newSelection.persistentModelID
                }) {
                    unreadTripIdentifiers.remove(at: index)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            Task {
                if phase == .active {
                    unreadTripIdentifiers += await DataModel.shared.findUnreadTripIdentifiers()
                } else {
                    await DataModel.shared.setUnreadTripIdentifiersInUserDefaults(unreadTripIdentifiers)
                }
            }
        }
        #if os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task {
                unreadTripIdentifiers += await DataModel.shared.findUnreadTripIdentifiers()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            Task {
                await DataModel.shared.setUnreadTripIdentifiersInUserDefaults(unreadTripIdentifiers)
            }
        }
        #endif
    }
}

extension ContentView {
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if selectedSegement == .all {
                addTripMenu
            } else {
                addTripButton
            }
        }
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            tripSegmentPicker
        }
        #endif
    }
    
    private var addTripMenu: some View {
        Menu("Add Trip", systemImage: "plus") {
            let segments: [Segment] = Segment.allCases.filter { $0 != .all }
            ForEach(segments, id: \.self) { segment in
                Button(segment.rawValue) {
                    newTripSegment = segment
                    showAddTrip = true
                }
            }
        }
    }
    
    private var addTripButton: some View {
        Button {
            newTripSegment = selectedSegement
            showAddTrip = true
        } label: {
            Label("Add Trip", systemImage: "plus")
        }
    }
    
    private var tripSegmentPicker: some View {
        Picker("", selection: $selectedSegement) {
            ForEach(Segment.allCases, id: \.self) { segment in
                Text(segment.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 250)
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    ContentView()
}
