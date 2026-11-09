//
//  JournalCardView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct JournalCardView: View {
    let journal: Journal
    let onBookmarkTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(journal.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appTextAccent)
                    .lineLimit(1)

                Spacer()

                Button(action: onBookmarkTap) {
                    Image(systemName: journal.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.appAccent)
                }
                .buttonStyle(.plain)
            }

            Text(journal.formattedDate)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.appTextSecondary)

            Text(journal.text)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(5)
                .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.appCard, in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        JournalCardView(
            journal: Journal(title: "My Birthday", text: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", date: Date(), isBookmarked: true),
            onBookmarkTap: {}
        )
        .padding()
    }
}
