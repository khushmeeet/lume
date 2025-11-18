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
                TabView(selection: $currentIndex) {
                    ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                        WikiArticleCardView(wikiArticle: article)
                            .offset(x: currentIndex == index ? dragOffset : 0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if currentIndex == index {
                                            // Only allow horizontal drag
                                            if abs(value.translation.width) > abs(value.translation.height) {
                                                dragOffset = value.translation.width
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        if currentIndex == index {
                                            handleSwipe(for: article, translation: value.translation.width)
                                        }
                                    }
                            )
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .environment(\.layoutDirection, .rightToLeft)
                .ignoresSafeArea()

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
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.9)))
                    Text("Favorite")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 50)
            } else if dragOffset > 50 {
                VStack {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.9)))
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
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
