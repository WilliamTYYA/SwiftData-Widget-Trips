//
//  TripsWidget.swift
//  SwiftData-Widget-Trip-WidgetExtensionExtension
//
//  Created by Thiha Ye Yint Aung on 11/20/25.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct TripsWidget: Widget {
    let kind: String = "TripsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TripsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Future Trips")
        .description("See your upcoming trips.")
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        .placeholderEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(.placeholderEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        var fetchDescriptor = FetchDescriptor(sortBy: [SortDescriptor(\Trip.startDate, order: .forward)])
        let now = Date.now
        fetchDescriptor.predicate = #Predicate { $0.endDate >= now }
        fetchDescriptor.fetchLimit = 1
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        
        if let upcomingTrips = try? modelContext.fetch(fetchDescriptor) {
            if let trip = upcomingTrips.first {
                var accommodationStatus = AccommodationStatus.noAccommodation
                if let livingAccommodation = trip.livingAccommodation {
                    accommodationStatus = livingAccommodation.isConfirmed ? .confirmed : .notConfirmed
                }
                let newEntry = SimpleEntry(date: now,
                                           startDate: trip.startDate,
                                           endDate: trip.endDate,
                                           name: trip.name,
                                           destination: trip.destination,
                                           accommodationStatus: accommodationStatus)
                let timeline = Timeline(entries: [newEntry], policy: .after(newEntry.endDate))
                completion(timeline)
                return
            }
        }
        
        let newEntry = SimpleEntry(date: now,
                                   startDate: now,
                                   endDate: now,
                                   name: "No Trips",
                                   destination: "",
                                   accommodationStatus: .noAccommodation)
        let timeline = Timeline(entries: [newEntry], policy: .never)
        completion(timeline)
    }
    
    
}

enum AccommodationStatus {
    case noAccommodation, notConfirmed, confirmed
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let startDate: Date
    let endDate: Date
    let name: String
    let destination: String
    let accommodationStatus: AccommodationStatus
    
    static var placeholderEntry: SimpleEntry {
        let now = Date()
        let sevenDaysAfter = Calendar.current.date(byAdding: .day, value: 7, to: now)
        return SimpleEntry(date: now, startDate: now, endDate: sevenDaysAfter ?? Date(),
                           name: "Honeymoon", destination: "Hawaii", accommodationStatus: .confirmed)
    }
}

struct TripsWidgetEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "car.circle")
                    .imageScale(.large)
                Text(entry.name)
                    .font(.system(.title2).weight(.semibold))
                    .minimumScaleFactor(0.5)
                Spacer()
            }
            .foregroundColor(.green)
            
            Divider()
            
            if !entry.destination.isEmpty {
                Group {
                    Text(entry.destination)
                        .font(.system(.title3).weight(.semibold))
                    Text(entry.startDate, style: .date)
                    Text(entry.endDate, style: .date)
                    Spacer()
                    
                    if entry.accommodationStatus != .noAccommodation {
                        Button(intent: AccommodationIntent(tripName: entry.name, startDate: entry.startDate, endDate: entry.endDate)) {
                            HStack {
                                Text("Accommodation")
                                Image(systemName: entry.accommodationStatus == .confirmed ? "checkmark.circle" : "circle")
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(entry.accommodationStatus == .confirmed ? .green :  .red)
                    } else {
                        Text("No accommodation.")
                    }
                }
                .foregroundColor(.gray)
                .minimumScaleFactor(0.5)
            }
        }
        .containerBackground(for: .widget) {
            Color.white
        }
    }
}

#Preview(as: .systemSmall) {
    TripsWidget()
} timeline: {
    SimpleEntry.placeholderEntry
}
