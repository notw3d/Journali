//
//  Journal.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import Foundation

// One journal entry. "Codable" lets us save it to a file and load it back.
struct Journal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var text: String
    var date: Date
    var isBookmarked = false

    // The date written like 02/09/2024
    var formattedDate: String {
        Journal.format(date)
    }

    static func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}
