//
//  LivingAccommodation.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/12/25.
//

import Foundation
import SwiftData

@Model class LivingAccommodation {
    var address: String
    var placeName: String
    var isConfirmed: Bool = false
    var trip: Trip?
    
    init(address: String, placeName: String, isConfirmed: Bool) {
        self.address = address
        self.placeName = placeName
        self.isConfirmed = isConfirmed
        self.trip = trip
    }
}

extension LivingAccommodation {
    var displayAddress: String {
        address.isEmpty ? "No Address" : address
    }
    
    var displayPlaceName: String {
        placeName.isEmpty ? "No Place Name" : placeName
    }
    
    static var preview: [LivingAccommodation] {
        [.init(address: "Yosemite National Park, CA 95389", placeName: "Yosemite", isConfirmed: true)]
    }
}
