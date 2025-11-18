//
//  LumeApp.swift
//  Lume
//
//  Created by Khushmeet Singh on 2/25/25.
//

import SwiftUI

@main
struct LumeApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            CustomTabView()
                .environmentObject(favoritesManager)
        }
    }
}

struct CustomTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                if selectedTab == 0 {
                    ContentView()
                } else {
                    FavoritesView()
                }
            }

            // Custom Tab Bar
            customTabBar
                .padding(.horizontal, PastelSpacing.large)
                .padding(.bottom, PastelSpacing.medium)
        }
        .ignoresSafeArea(.keyboard)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Discover Tab
            TabBarButton(
                icon: "safari",
                title: "Discover",
                isSelected: selectedTab == 0,
                action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 0 } }
            )

            // Favorites Tab
            TabBarButton(
                icon: "heart.fill",
                title: "Favorites",
                isSelected: selectedTab == 1,
                action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 } }
            )
        }
        .padding(.horizontal, PastelSpacing.small)
        .padding(.vertical, PastelSpacing.small)
        .background(
            Capsule()
                .fill(Color.cardBackground)
                .shadow(
                    color: PastelShadow.medium.color,
                    radius: PastelShadow.medium.radius,
                    x: PastelShadow.medium.x,
                    y: PastelShadow.medium.y
                )
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PastelSpacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))

                if isSelected {
                    Text(title)
                        .font(PastelTypography.bodyMedium)
                }
            }
            .foregroundColor(isSelected ? .primaryText : .secondaryText)
            .padding(.horizontal, PastelSpacing.large)
            .padding(.vertical, PastelSpacing.medium)
            .background(
                Capsule()
                    .fill(isSelected ? Color.pastelLavender : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
