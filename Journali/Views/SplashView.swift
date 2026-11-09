//
//  SplashView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Background: black at the top, fading into the card color at the bottom
            LinearGradient(
                colors: [Color.appBackground, Color.appCard],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Icon, name and tagline stacked on top of the background
            VStack(spacing: 12) {
                Image("book1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 110)

                Text("Journali")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color.appTextPrimary)

                Text("Your thoughts, your story")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

#Preview {
    SplashView()
}
