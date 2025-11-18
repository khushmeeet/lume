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
    
    struct Thumbnail: Codable {
        let source: String
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case extract
        case thumbnail
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
