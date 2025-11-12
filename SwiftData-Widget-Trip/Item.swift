//
//  Item.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/12/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
