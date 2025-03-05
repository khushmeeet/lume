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
    
    func fetchArticle(count: Int = 10) -> AnyPublisher<[WikiArticle], Error> {
        let endpoint = "/page/random/summary"
        let url = URL(string: baseURL + endpoint)!
        
        let singleArticlePublisher = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WikiArticle.self, decoder: JSONDecoder())
        
        let publishers = (0..<count).map { _ in singleArticlePublisher }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
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
