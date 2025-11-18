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
        ZStack {
            // Background
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                customHeader

                if favoritesManager.favorites.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PastelSpacing.medium) {
                            ForEach(favoritesManager.favorites) { favorite in
                                FavoriteRowView(favorite: favorite, onDelete: {
                                    favoritesManager.removeFavorite(favorite)
                                })
                            }
                        }
                        .padding(.horizontal, PastelSpacing.large)
                        .padding(.vertical, PastelSpacing.medium)
                    }
                }
            }
        }
    }

    private var customHeader: some View {
        VStack(spacing: PastelSpacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Favorites")
                        .font(PastelTypography.largeTitle)
                        .foregroundColor(.primaryText)

                    if !favoritesManager.favorites.isEmpty {
                        Text("\(favoritesManager.favorites.count) articles saved")
                            .font(PastelTypography.caption)
                            .foregroundColor(.secondaryText)
                    }
                }

                Spacer()

                // Heart icon with gradient
                ZStack {
                    Circle()
                        .fill(PastelGradient.accent)
                        .frame(width: 50, height: 50)
                        .shadow(
                            color: PastelShadow.soft.color,
                            radius: PastelShadow.soft.radius,
                            x: PastelShadow.soft.x,
                            y: PastelShadow.soft.y
                        )

                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
            .padding(.horizontal, PastelSpacing.large)
            .padding(.top, PastelSpacing.large)
            .padding(.bottom, PastelSpacing.medium)

            PastelDivider()
        }
        .background(Color.cardBackground)
    }

    private var emptyStateView: some View {
        VStack(spacing: PastelSpacing.large) {
            Spacer()

            ZStack {
                Circle()
                    .fill(PastelGradient.primary)
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.pastelWhite)
            }

            VStack(spacing: PastelSpacing.small) {
                Text("No favorites yet")
                    .font(PastelTypography.title)
                    .foregroundColor(.primaryText)

                Text("Articles you favorite will appear here")
                    .font(PastelTypography.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PastelSpacing.extraLarge)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoriteRowView: View {
    let favorite: FavoriteArticle
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0
    @State private var isSwiping = false

    var body: some View {
        ZStack {
            // Delete background
            HStack {
                Spacer()
                Button(action: onDelete) {
                    VStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 24, weight: .semibold))
                        Text("Delete")
                            .font(PastelTypography.captionMedium)
                    }
                    .foregroundColor(.pastelWhite)
                }
                .padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: PastelCornerRadius.medium)
                    .fill(Color.pastelRose)
            )

            // Main content
            HStack(spacing: PastelSpacing.medium) {
                // Thumbnail
                if let urlString = favorite.thumbnailURLString,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(PastelGradient.secondary)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.pastelWhite.opacity(0.5))
                            )
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: PastelCornerRadius.small))
                } else {
                    RoundedRectangle(cornerRadius: PastelCornerRadius.small)
                        .fill(PastelGradient.secondary)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.pastelWhite.opacity(0.5))
                        )
                }

                // Text content
                VStack(alignment: .leading, spacing: PastelSpacing.small) {
                    Text(favorite.title)
                        .font(PastelTypography.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(favorite.extract)
                        .font(PastelTypography.caption)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(PastelSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PastelCornerRadius.medium)
                    .fill(Color.cardBackground)
                    .shadow(
                        color: PastelShadow.soft.color,
                        radius: PastelShadow.soft.radius,
                        x: PastelShadow.soft.x,
                        y: PastelShadow.soft.y
                    )
            )
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if value.translation.width < -100 {
                                offset = -100
                                isSwiping = true
                            } else {
                                offset = 0
                                isSwiping = false
                            }
                        }
                    }
            )
        }
    }
}
