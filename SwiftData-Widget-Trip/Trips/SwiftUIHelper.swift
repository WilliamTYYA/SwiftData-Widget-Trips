//
//  SwiftUIHelper.swift
//  SwiftData-Widget-Trip
//
//  Created by Thiha Ye Yint Aung on 11/15/25.
//

import SwiftUI

#if os(macOS)
typealias TripForm = List
typealias TripGroupBox = GroupBox
#else
typealias TripForm = Form
typealias TripGroupBox = Group
#endif

extension Color {
    static var tripGray: Color {
        #if os(iOS)
        return Color(.systemGray6)
        #else
        return Color.gray
        #endif
    }
}

@MainActor
extension ToolbarItemPlacement {
    #if os(macOS)
    static let topBarLeading = automatic
    static let topBarTrailing = automatic
    static let bottomBar = automatic
    #endif
}

struct LayoutConstants {
    static let sheetIdealWidth = 400.0
    static let sheetIdealHeight = 500.0
}


