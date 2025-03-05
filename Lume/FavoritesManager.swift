//
//  FavoritesManager.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/5/25.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteArticle] = []
    
    private let favoritesKey = "SavedFavorites"
    
    init() {
        loadFavorites()
    }
    
    func addFavorite(_ article: WikiArticle) {
        let favorite = article.asFavorite
        if !favorites.contains(where: { $0.title == favorite.title }) {
            favorites.append(favorite)
            saveFavorites()
        }
    }
    
    func removeFavorite(_ favorite: FavoriteArticle) {
        favorites.removeAll { $0.id == favorite.id }
        saveFavorites()
    }
    
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            let decoded = try! JSONDecoder().decode([FavoriteArticle].self, from: data)
            favorites = decoded
        }
    }
}
