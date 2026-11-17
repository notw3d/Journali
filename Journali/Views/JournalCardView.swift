//
//  JournalCardView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct JournalCardView: View {
    let journal: Journal
    // اليومية التي يعرضها الكرت. let لأن الكرت يعرض فقط ولا يغيّر شيئاً

    let onBookmarkTap: () -> Void
    // "الجرس": الكرت يشغّله عند الضغط على البوكمارك، وصفحة MainView هي التي تقرر ماذا يحدث

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack(alignment: .top) {

                Text(journal.title)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appTextAccent)
                    .lineLimit(1)

                Spacer()

                Button(action: onBookmarkTap) {
                    // عند الضغط يشغّل الـ closure الذي استلمه الكرت

                    Image(systemName: journal.isBookmarked ? "bookmark.fill" : "bookmark")
                        // شرط ? أ : ب  إذا اليومية في المفضلة أيقونة ممتلئة، وإلا أيقونة فاضية
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
        // يجعل الكرت بعرض الشاشة كاملة، والمحتوى ملتصق باليسار

        .padding(20)
        // padding: مسافة داخل الكرت. الترتيب مهم: لازم قبل الـ background

        .background(Color.appCard, in: RoundedRectangle(cornerRadius: 24))
        // background: الصندوق الداكن بزوايا مدورة. جاء بعد الـ padding ليشمل المسافة
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
