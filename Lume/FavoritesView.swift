//
//  FavoritesView.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/5/25.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        NavigationView {
            if favoritesManager.favorites.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(favoritesManager.favorites) { favorite in
                        FavoriteRowView(favorite: favorite)
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Favorite Articles")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 72))
                .foregroundColor(.gray)
            
            Text("No favorite yet.")
                .font(.title)
                .fontWeight(.medium)
            
            Text("Articles you favorite will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .navigationTitle("Favorites")
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favoritesManager.favorites[index]
            favoritesManager.removeFavorite(favorite)
        }
    }
}

struct FavoriteRowView: View {
    let favorite: FavoriteArticle
    
    var body: some View {
        HStack(spacing: 12) {
            if let urlString = favorite.thumbnailURLString,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(favorite.extract)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
