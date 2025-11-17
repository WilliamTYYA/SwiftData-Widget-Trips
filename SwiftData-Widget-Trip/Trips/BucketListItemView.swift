//
//  BucketListItemView.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/17/25.
//

import SwiftUI

struct BucketListItemView: View {
    var item: BucketListItem
    
    var body: some View {
        TripForm {
            
            Section {
                VStack(alignment: .leading) {
                    TripGroupBox {
                        HStack {
                            Text(item.details.isEmpty ? "<No details>" : item.details)
                            Spacer()
                        }
                    }
                    TripGroupBox {
                        HStack {
                            Text("Reservations made: ")
                            Spacer()
                            Text(item.hasReservation ? "YES" : "NO")
                        }
                        HStack {
                            Text("Already in plan: ")
                            Spacer()
                            Text(item.isInPlan ? "YES" : "NO")
                        }
                    }
                }
            } header: {
                Text("Bucket List Item Details")
            }
        }
        .navigationTitle(item.title)
    }
}

#Preview(traits: .sampleData) {
    BucketListItemView(item: .preview)
}
