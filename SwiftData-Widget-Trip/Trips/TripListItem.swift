//
//  TripListItem.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/15/25.
//

import SwiftUI
import SwiftData

struct TripListItem: View {
    let trip: Trip
    let unread: Bool
    
    var body: some View {
        NavigationLink(value: trip) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(trip.color)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Text(String(trip.displayName.first!))
                            .font(.system(size: 48))
                            .foregroundStyle(.background)
                    }
                
                Circle()
                    .fill(unread ? Color.blue : Color.clear)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading) {
                    Text(trip.displayName)
                        .font(.headline)
                    Text(trip.destination)
                        .font(.subheadline)
                    
                    Divider()
                    
                    HStack {
                        Text(trip.startDate, style: .date)
                        Image(systemName: "arrow.right")
                        Text(trip.endDate, style: .date)
                    }
                    .font(.caption)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    List {
        TripListItem(trip: trips.first!, unread: false)
    }
    
}
