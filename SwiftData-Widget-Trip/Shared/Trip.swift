//
//  Trip.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/12/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model class Trip {
    @Attribute(.preserveValueOnDeletion)
    var name: String
    var destination: String
    
    @Attribute(.preserveValueOnDeletion)
    var startDate: Date
    
    @Attribute(.preserveValueOnDeletion)
    var endDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \BucketListItem.trip)
    var bucketListItems: [BucketListItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \LivingAccommodation.trip)
    var livingAccommodation: LivingAccommodation?
    
    init(name: String, destination: String, startDate: Date = .now, endDate: Date = .distantFuture) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var color: Color {
        Color.yellow
    }
}

@available(iOS 26.0, *)
@Model
class PersonalTrip: Trip {
    
    enum Reason: String, CaseIterable, Codable, Identifiable {
        case family
        case reunion
        case wellness
        case unknown
        
        var id: Self { self }
    }
    var reason: Reason
    
    init(name: String, destination: String, startDate: Date = .now, endDate: Date = .distantFuture, reason: Reason) {
        self.reason = reason
        super.init(name: name, destination: destination, startDate: startDate, endDate: endDate)
    }
    
    override var color: Color {
        return .blue
    }
}

@available(iOS 26.0, *)
@Model
class BusinessTrip: Trip {
    var perdiem: Double = 0.0
    
    init(name: String, destination: String, startDate: Date = .now, endDate: Date = .distantFuture, perdiem: Double?) {
        if let perdiem = perdiem {
            self.perdiem = perdiem
        }
        super.init(name: name, destination: destination, startDate: startDate, endDate: endDate)
    }
    
    override var color: Color {
        return .green
    }
}

extension Trip {
    var displayName: String {
        name.isEmpty ? "Untitled Trip" : name
    }
    
    var displayDestination: String {
        destination.isEmpty ? "Untitled Destination" : destination
    }
    
    static var preview: Trip {
        Trip(name: "Trip Name", destination: "Trip destination",
             startDate: .now, endDate: .now.addingTimeInterval(4 * 3600))
    }
    
    private static func date(calendar: Calendar = Calendar(identifier: .gregorian),
                             timezone: TimeZone = TimeZone.current,
                             year: Int, month: Int, day: Int) -> Date {
        let dateComponent = DateComponents(calendar: calendar, timeZone: timezone,
                                           year: year, month: month, day: day)
        let date = calendar.date(from: dateComponent)
        return date ?? .now
    }
    
    static var previewTrips: [Trip] {
        [
            BusinessTrip(name: "WWDC2025", destination: "Cupertino",
                         startDate: date(year: 2025, month: 6, day: 9),
                         endDate: date(year: 2025, month: 6, day: 13),
                         perdiem: 123.45),
            PersonalTrip(name: "Camping!", destination: "Yosemite",
                         startDate: date(year: 2025, month: 6, day: 27),
                         endDate: date(year: 2025, month: 7, day: 1),
                         reason: .family),
            PersonalTrip(name: "Bridalveil Falls", destination: "Yosemite",
                         startDate: date(year: 2025, month: 6, day: 28),
                         endDate: date(year: 2025, month: 6, day: 28),
                         reason: .family),
            Trip(name: "City Hall", destination: "San Francisco",
                 startDate: date(year: 2025, month: 7, day: 2),
                 endDate: date(year: 2025, month: 7, day: 7))
        ]
    }
}

