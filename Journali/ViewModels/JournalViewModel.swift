//
//  JournalViewModel.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI
import Combine

// The two ways the list can be sorted.
enum SortOption {
    case entryDate
    case bookmark
}

// The "brain" of the app: it holds all journals and the logic to change them.
class JournalViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    @Published var searchText = ""
    @Published var sortOption: SortOption = .entryDate

    private let fileURL: URL

    init() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = folder.appendingPathComponent("journals.json")
        load()
    }

    // The journals the screen should show: searched, then sorted.
    var displayedJournals: [Journal] {
        var result = journals

        if !searchText.isEmpty {
            result = result.filter { journal in
                journal.title.localizedCaseInsensitiveContains(searchText) ||
                journal.text.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortOption {
        case .entryDate:
            result.sort { $0.date > $1.date }
        case .bookmark:
            result.sort { first, second in
                if first.isBookmarked != second.isBookmarked {
                    return first.isBookmarked
                }
                return first.date > second.date
            }
        }

        return result
    }

    func add(title: String, text: String) {
        let newJournal = Journal(title: title, text: text, date: Date())
        journals.append(newJournal)
        save()
    }

    func update(_ journal: Journal, title: String, text: String) {
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else { return }
        journals[index].title = title
        journals[index].text = text
        journals[index].date = Date()
        save()
    }

    func delete(_ journal: Journal) {
        journals.removeAll { $0.id == journal.id }
        save()
    }

    func toggleBookmark(_ journal: Journal) {
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else { return }
        journals[index].isBookmarked.toggle()
        save()
    }

    // Saving and loading: journals are stored in a small file on the phone.
    private func save() {
        do {
            let data = try JSONEncoder().encode(journals)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Could not save journals: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let savedJournals = try? JSONDecoder().decode([Journal].self, from: data) {
            journals = savedJournals
        }
    }
}
