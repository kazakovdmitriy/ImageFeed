//
//  UserResult.swift
//  ImageFeed
//
//  Created by Дмитрий on 26.05.2024.
//


import Foundation

// MARK: - UserResult
struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Codable {
    let small, medium, large: String
}
