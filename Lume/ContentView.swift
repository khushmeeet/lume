//
//  ContentView.swift
//  Lume
//
//  Created by Khushmeet Singh on 2/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WikiArticleViewModel()
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showShareSheet = false
    @State private var articleToShare: WikiArticle?

    var body: some View {
        ZStack {
            if viewModel.articles.isEmpty {
                MainLoadingView()
                    .onAppear {
                        viewModel.loadArticles()
                    }
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                                WikiArticleCardView(wikiArticle: article)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .offset(x: currentIndex == index ? dragOffset : 0)
                                    .gesture(
                                        DragGesture(minimumDistance: 20)
                                            .onChanged { value in
                                                // Only allow horizontal drag if it's clearly horizontal
                                                // Require significantly more horizontal movement than vertical
                                                if abs(value.translation.width) > abs(value.translation.height) * 2.5 {
                                                    if currentIndex == index {
                                                        dragOffset = value.translation.width
                                                    }
                                                }
                                            }
                                            .onEnded { value in
                                                // Only trigger swipe if it's clearly horizontal
                                                if abs(value.translation.width) > abs(value.translation.height) * 2.5
                                                    && abs(value.translation.width) > 30 {
                                                    if currentIndex == index {
                                                        handleSwipe(for: article, translation: value.translation.width)
                                                    }
                                                } else {
                                                    // Reset offset if swipe wasn't completed
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        dragOffset = 0
                                                    }
                                                }
                                            }
                                    )
                                    .containerRelativeFrame(.vertical)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.8)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                    }
                                    .onAppear {
                                        currentIndex = index
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollBounceBehavior(.basedOnSize)
                    .ignoresSafeArea()
                }

                // Swipe indicator overlay
                if abs(dragOffset) > 50 {
                    swipeIndicatorOverlay
                }
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showShareSheet) {
            if let article = articleToShare {
                ShareSheet(items: [article.shareURL])
            }
        }
    }

    // MARK: - Helper Methods

    private func handleSwipe(for article: WikiArticle, translation: CGFloat) {
        let swipeThreshold: CGFloat = 100

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if translation < -swipeThreshold {
                // Swipe left - Add to favorites
                favoritesManager.addFavorite(article)
                triggerHapticFeedback()
            } else if translation > swipeThreshold {
                // Swipe right - Share
                articleToShare = article
                showShareSheet = true
            }

            // Reset offset
            dragOffset = 0
        }
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private var swipeIndicatorOverlay: some View {
        HStack {
            if dragOffset < -50 {
                Spacer()
                VStack(spacing: PastelSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(Color.favoriteColor)
                            .frame(width: 80, height: 80)
                            .shadow(
                                color: PastelShadow.strong.color,
                                radius: PastelShadow.strong.radius,
                                x: PastelShadow.strong.x,
                                y: PastelShadow.strong.y
                            )
                        Image(systemName: "heart.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.primaryText)
                    }
                    Text("Favorite")
                        .font(PastelTypography.headline)
                        .foregroundColor(.pastelWhite)
                        .padding(.horizontal, PastelSpacing.medium)
                        .padding(.vertical, PastelSpacing.small)
                        .background(
                            Capsule()
                                .fill(Color.pastelCharcoal.opacity(0.7))
                        )
                }
                .padding(.trailing, 50)
            } else if dragOffset > 50 {
                VStack(spacing: PastelSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(Color.shareColor)
                            .frame(width: 80, height: 80)
                            .shadow(
                                color: PastelShadow.strong.color,
                                radius: PastelShadow.strong.radius,
                                x: PastelShadow.strong.x,
                                y: PastelShadow.strong.y
                            )
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.primaryText)
                    }
                    Text("Share")
                        .font(PastelTypography.headline)
                        .foregroundColor(.pastelWhite)
                        .padding(.horizontal, PastelSpacing.medium)
                        .padding(.vertical, PastelSpacing.small)
                        .background(
                            Capsule()
                                .fill(Color.pastelCharcoal.opacity(0.7))
                        )
                }
                .padding(.leading, 50)
                Spacer()
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
        .environmentObject(FavoritesManager())
}
