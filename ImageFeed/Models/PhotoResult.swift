//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Дмитрий on 29.05.2024.
//

import Foundation

// MARK: - PhotoResultElement
struct PhotoResultElement: Codable {
    let id: String
    let createdAt, updatedAt: Date
    let width, height: Int
    let color, blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String
    let currentUserCollections: [CurrentUserCollection]
    let urls: Urls
    let links: PhotoResultLinks

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case currentUserCollections = "current_user_collections"
        case urls, links
    }
}

// MARK: - CurrentUserCollection
struct CurrentUserCollection: Codable {
    let id: Int?
    let title: String?
    let publishedAt, lastCollectedAt, updatedAt: Date?
    let coverPhoto, user: JSONNull?
    let currentUserCollectionSelf, html, photos, likes: String?
    let portfolio: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case publishedAt = "published_at"
        case lastCollectedAt = "last_collected_at"
        case updatedAt = "updated_at"
        case coverPhoto = "cover_photo"
        case user
        case currentUserCollectionSelf = "self"
        case html, photos, likes, portfolio
    }
}

// MARK: - PhotoResultLinks
struct PhotoResultLinks: Codable {
    let linksSelf, html, download, downloadLocation: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case html, download
        case downloadLocation = "download_location"
    }
}

// MARK: - Urls
struct Urls: Codable {
    let raw, full, regular, small: String
    let thumb: String
}

typealias PhotoResult = [PhotoResultElement]

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
