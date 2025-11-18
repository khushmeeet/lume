//
//  WikiArticleCardView.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/3/25.
//

import SwiftUI

struct WikiArticleCardView: View {
    let wikiArticle: WikiArticle
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background gradient or color
                Color.black
                    .ignoresSafeArea()

                // Header image at top (limited height)
                if let thumbnail = wikiArticle.thumbnail,
                   let url = URL(string: thumbnail.source) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.5, 400))
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8), .black]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.5, 400))
                    }
                }

                // Content overlay
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: max(0, min(geometry.size.height * 0.35, 300)))

                    Text(wikiArticle.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Wikipedia")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))

                            Text(wikiArticle.extract)
                                .font(.body)
                                .foregroundColor(.white)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .background(
                        Color.black.opacity(0.3)
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
