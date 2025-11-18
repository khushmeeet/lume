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
                // Animated gradient background
                AnimatedGradientBackground()

                VStack(spacing: 0) {
                    // Header image with custom styling
                    if let thumbnail = wikiArticle.thumbnail,
                       let url = URL(string: thumbnail.source) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: min(geometry.size.height * 0.45, 380))
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .clear,
                                            .primaryBackground.opacity(0.4),
                                            .primaryBackground.opacity(0.9)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(PastelCornerRadius.large, corners: [.bottomLeft, .bottomRight])
                        } placeholder: {
                            Rectangle()
                                .fill(PastelGradient.primary)
                                .frame(width: geometry.size.width, height: min(geometry.size.height * 0.45, 380))
                                .overlay(
                                    Image(systemName: "photo.artframe")
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(.pastelWhite.opacity(0.5))
                                )
                                .cornerRadius(PastelCornerRadius.large, corners: [.bottomLeft, .bottomRight])
                        }
                    } else {
                        Rectangle()
                            .fill(PastelGradient.primary)
                            .frame(width: geometry.size.width, height: min(geometry.size.height * 0.45, 380))
                            .overlay(
                                Image(systemName: "photo.artframe")
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundColor(.pastelWhite.opacity(0.5))
                            )
                            .cornerRadius(PastelCornerRadius.large, corners: [.bottomLeft, .bottomRight])
                    }

                    // Content section
                    VStack(alignment: .leading, spacing: PastelSpacing.medium) {
                        // Wikipedia tag
                        HStack {
                            PastelTag(text: "Wikipedia", backgroundColor: .pastelLavender)
                            Spacer()
                        }
                        .padding(.horizontal, PastelSpacing.large)
                        .padding(.top, PastelSpacing.small)

                        // Title
                        Text(wikiArticle.title)
                            .font(PastelTypography.largeTitle)
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, PastelSpacing.large)

                        // Content scroll
                        ScrollView(.vertical, showsIndicators: false) {
                            Text(wikiArticle.extract)
                                .font(PastelTypography.body)
                                .foregroundColor(.secondaryText)
                                .lineSpacing(6)
                                .padding(.horizontal, PastelSpacing.large)
                                .padding(.vertical, PastelSpacing.small)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(
                        Color.primaryBackground.opacity(0.95)
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

// Helper for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
