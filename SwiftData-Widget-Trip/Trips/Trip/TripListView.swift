//
//  TripListView.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/15/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .forward)
    var trips: [Trip]
    
    @Binding var selection: Trip?
    var unreadTripIdentifiers: [PersistentIdentifier]
    @Binding var tripCount: Int
    
    init(selection: Binding<Trip?>, segment: ContentView.Segment, unreadTripIdentifiers: [PersistentIdentifier], tripCount: Binding<Int>, searchText: String) {
        _selection = selection
        self.unreadTripIdentifiers = unreadTripIdentifiers
        _tripCount = tripCount
        
        let searchPredicate = #Predicate<Trip> {
            searchText.isEmpty ? true : $0.name.localizedStandardContains(searchText) || $0.destination.localizedStandardContains(searchText)
        }
        let classPredicate: Predicate<Trip>? = {
            switch segment {
            case .all: return nil
            case .personal: return #Predicate<Trip> { $0 is PersonalTrip }
            case .business: return #Predicate<Trip> { $0 is BusinessTrip }
            }
        }()
        
        let fullPredicate: Predicate<Trip>
        if let classPredicate {
            fullPredicate = #Predicate<Trip> { searchPredicate.evaluate($0) && classPredicate.evaluate($0) }
        } else {
            fullPredicate = searchPredicate
        }
        
        _trips = Query(filter: fullPredicate, sort: \Trip.startDate, order: .forward)
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(trips) { trip in
                TripListItem(trip: trip, unread: unreadTripIdentifiers.contains(trip.persistentModelID))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteTrip(trip)
                            WidgetCenter.shared.reloadTimelines(ofKind: "TripsWidget")
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: deleteTrip(at:))
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView {
                        Label("No Trips", systemImage: "car.circle")
                    } description: {
                        Text("New trips you create will appear here.")
                    }
                }
            }
            .navigationTitle("Upcoming Trips")
            .onChange(of: trips) { _, newValue in
                tripCount = trips.count
            }
            .onAppear {
                tripCount = trips.count
            }
        }
    }
}

extension TripListView {
    private func deleteTrip(at offset: IndexSet) {
        withAnimation {
            offset.map { trips[$0] }.forEach { trip in
                deleteTrip(trip)
            }
        }
    }
    private func deleteTrip(_ trip: Trip) {
        if trip.persistentModelID == selection?.persistentModelID {
            selection = nil
        }
        modelContext.delete(trip)
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    
    @Previewable @State var selection: Trip? = nil
    @Previewable @State var tripCount: Int = 0
    TripListView(selection: $selection, segment: .all, unreadTripIdentifiers: [trips.first!.persistentModelID], tripCount: $tripCount, searchText: "")
}
