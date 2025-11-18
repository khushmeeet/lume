//
//  WikiArticleViewModel.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/3/25.
//

import Foundation
import Combine

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}


class WikiArticleViewModel: ObservableObject {
    @Published var articles: [WikiArticle] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var alertItem: AlertItem? = nil
    
    private let wikipediaService = WikipediaService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadArticles() {
        isLoading = true

        wikipediaService.fetchArticle()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.showError("Failed to load articles. Please check your internet connection and try again.")
                }
            }, receiveValue: { [weak self] articles in
                self?.articles = articles
            })
            .store(in: &cancellables)
    }
    
    private func showError(_ message: String) {
        alertItem = AlertItem(title: "Error", message: message)
    }
}
