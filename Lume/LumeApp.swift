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
            TabView {
                ContentView()
                    .tabItem {
                        Label("Discover", systemImage: "safari")
                    }
                
                FavoritesView()
                    .tabItem {
                        Label("Favorite", systemImage: "heart.fill")
                    }
            }
            .environmentObject(favoritesManager)
        }
    }
}
