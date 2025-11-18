//
//  WikiArticle.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/3/25.
//

import Foundation

struct WikiArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let extract: String
    let thumbnail: Thumbnail?
    let description: String?
    let contentUrls: ContentUrls?

    // Computed property for quality scoring
    var qualityScore: Double {
        var score = 0.0

        // Prefer articles with thumbnails (visual content)
        if thumbnail != nil {
            score += 30.0
        }

        // Prefer articles with substantial content (200+ chars is good, 400+ is excellent)
        let extractLength = Double(extract.count)
        if extractLength > 400 {
            score += 40.0
        } else if extractLength > 200 {
            score += 25.0
        } else if extractLength > 100 {
            score += 10.0
        }

        // Prefer articles with descriptions
        if description != nil && !description!.isEmpty {
            score += 15.0
        }

        // Bonus for longer titles (often indicate specific, interesting topics)
        if title.count > 30 {
            score += 15.0
        } else if title.count > 15 {
            score += 10.0
        }

        return score
    }

    struct Thumbnail: Codable {
        let source: String
    }

    struct ContentUrls: Codable {
        let desktop: DesktopUrl?

        struct DesktopUrl: Codable {
            let page: String
        }
    }

    enum CodingKeys: String, CodingKey {
        case title
        case extract
        case thumbnail
        case description
        case contentUrls = "content_urls"
    }
}

extension WikiArticle {
    var asFavorite: FavoriteArticle {
        FavoriteArticle(
            title: title, extract: extract, thumbnailURLString: thumbnail?.source
        )
    }

    var shareURL: URL {
        // Wikipedia URL format: https://en.wikipedia.org/wiki/Article_Title
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? title
        return URL(string: "https://en.wikipedia.org/wiki/\(encodedTitle)") ?? URL(string: "https://en.wikipedia.org")!
    }
}

struct FavoriteArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let extract: String
    let thumbnailURLString: String?
    
    var thumbnail: URL? {
        guard let string = thumbnailURLString else { return nil }
        return URL(string: string)
    }
}
