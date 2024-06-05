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
    let createdAt: Date
    let width, height: Int
    let color, blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: Urls
    let links: PhotoResultLinks

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls, links
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
