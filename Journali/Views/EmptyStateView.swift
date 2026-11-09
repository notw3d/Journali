//
//  EmptyStateView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("book2")
                .resizable()
                .scaledToFit()
                .frame(height: 110)

            Text("Begin Your Journal")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.appTextAccent)

            Text("Craft your personal diary, tap the plus icon to begin")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 60)
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        EmptyStateView()
    }
}
