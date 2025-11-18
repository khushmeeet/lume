//
//  WikipediaService.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/3/25.
//

import Foundation
import Combine

class WikipediaService {
    private let baseURL = "https://en.wikipedia.org/api/rest_v1"

    // Curated search queries focused on interesting, deep content
    private let interestingQueries = [
        // Historical Events & Periods
        "ancient civilization", "historical battle", "revolution", "medieval period",
        "renaissance", "world war", "empire", "dynasty", "archeological discovery",
        "historical figure", "ancient wonder", "historical monument",

        // Places & Geography
        "mountain", "volcano", "desert", "rainforest", "ocean", "island",
        "national park", "UNESCO world heritage", "ancient city", "landmark",
        "natural wonder", "geological formation", "canyon", "waterfall",

        // People & Biographies
        "scientist", "explorer", "inventor", "philosopher", "artist",
        "composer", "mathematician", "astronomer", "naturalist", "pioneer",

        // Science & Discovery
        "scientific discovery", "space exploration", "particle physics",
        "astronomy", "biology", "chemistry", "geology", "paleontology",
        "evolution", "quantum", "cosmos", "dinosaur", "extinct species",

        // Cultural & Fascinating
        "mythology", "legend", "ancient ritual", "archaeological site",
        "mysterious", "unexplained phenomenon", "cultural tradition",
        "architectural marvel", "engineering feat", "ancient technology"
    ]

    func fetchArticle(count: Int = 10) -> AnyPublisher<[WikiArticle], Error> {
        // Fetch more articles than needed so we can filter and rank them
        let fetchCount = count * 3

        // Create publishers for curated searches
        let publishers = (0..<fetchCount).map { _ -> AnyPublisher<WikiArticle, Error> in
            // Randomly select a query from our curated list
            let query = interestingQueries.randomElement() ?? "history"
            return self.searchArticle(query: query)
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .map { articles in
                // Filter out low-quality articles (too short, no images)
                let filtered = articles.filter { article in
                    article.extract.count > 100 && // Minimum content length
                    article.qualityScore > 30.0    // Minimum quality threshold
                }

                // Sort by quality score and take the top articles
                let sorted = filtered.sorted { $0.qualityScore > $1.qualityScore }

                // Return the requested count of best articles
                return Array(sorted.prefix(count))
            }
            .eraseToAnyPublisher()
    }

    private func searchArticle(query: String) -> AnyPublisher<WikiArticle, Error> {
        // Use Wikipedia's search API to find relevant articles
        let searchURL = "https://en.wikipedia.org/w/api.php"
        var components = URLComponents(string: searchURL)!

        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "generator", value: "search"),
            URLQueryItem(name: "gsrsearch", value: query),
            URLQueryItem(name: "gsrlimit", value: "5"),
            URLQueryItem(name: "prop", value: "pageimages|extracts"),
            URLQueryItem(name: "exintro", value: "1"),
            URLQueryItem(name: "explaintext", value: "1"),
            URLQueryItem(name: "exsentences", value: "3"),
            URLQueryItem(name: "piprop", value: "thumbnail"),
            URLQueryItem(name: "pithumbsize", value: "500")
        ]

        guard let url = components.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .tryMap { response -> String in
                // Extract a random page from the search results
                guard let pages = response.query?.pages,
                      let randomPage = pages.values.randomElement() else {
                    throw URLError(.cannotParseResponse)
                }
                return randomPage.title
            }
            .flatMap { title in
                // Fetch the full summary for this article
                self.fetchSummary(title: title)
            }
            .eraseToAnyPublisher()
    }

    private func fetchSummary(title: String) -> AnyPublisher<WikiArticle, Error> {
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
        let endpoint = "/page/summary/\(encodedTitle)"
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WikiArticle.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - Search Response Models
private struct SearchResponse: Codable {
    let query: Query?

    struct Query: Codable {
        let pages: [String: Page]?
    }

    struct Page: Codable {
        let title: String
    }
}


//class WikipediaService {
//    // Base URL for the Wikipedia API
//    private let baseURL = "https://en.wikipedia.org/api/rest_v1"
//
//    // Structure to match Wikipedia's API response
//    struct WikiResponse: Codable {
//        let title: String
//        let extract: String
//        let thumbnail: ThumbnailInfo?
//
//        struct ThumbnailInfo: Codable {
//            let source: URL
//        }
//    }
//
//    // Function to fetch random articles
//    func fetchRandomArticles(count: Int = 10) -> AnyPublisher<[WikiArticle], Error> {
//        // Create URL for the random articles endpoint
//        let endpoint = "/page/random/summary"
//        let url = URL(string: baseURL + endpoint)!
//
//        // Create a function that returns a fresh publisher for one article
//        func createSingleArticlePublisher() -> AnyPublisher<WikiArticle, Error> {
//            return URLSession.shared.dataTaskPublisher(for: url)
//                .map(\.data)
//                .decode(type: WikiResponse.self, decoder: JSONDecoder())
//                .tryMap { (response: WikiResponse) -> WikiArticle in
//                    return WikiArticle(
//                        title: response.title,
//                        extract: response.extract,
//                        thumbnail: response.thumbnail?.source
//                    )
//                }
//                .eraseToAnyPublisher()
//        }
//
//        // Create an array of these publishers to fetch multiple articles
//        let publishers = (0..<count).map { _ in createSingleArticlePublisher() }
//
//        // Combine all publishers and return as a single publisher of array
//        return Publishers.MergeMany(publishers)
//            .collect()
//            .eraseToAnyPublisher()
//    }
//}
