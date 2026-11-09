//
//  Colors.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

// All the colors from the Journali design, in one place.
extension Color {
    static let appAccent = Color(hex: 0x7F81FF)         // Save button, active actions
    static let appTextAccent = Color(hex: 0xAF99FD)     // Journal titles, empty-state heading
    static let appTextPrimary = Color(hex: 0xFFFFFF)    // Main headings, journal content
    static let appTextSecondary = Color(hex: 0xA39A9A)  // Entry dates
    static let appCard = Color(hex: 0x1C1C1E)           // Journal cards
    static let appBackground = Color(hex: 0x000000)     // Main screen background
    static let appDestructive = Color(hex: 0xFD453C)    // Delete action
}

// A small helper that turns a hex code like 0x7F81FF into a Color.
extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
