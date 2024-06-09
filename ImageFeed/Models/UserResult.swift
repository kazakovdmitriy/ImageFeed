//
//  UserResult.swift
//  ImageFeed
//
//  Created by Дмитрий on 26.05.2024.
//


import Foundation

// MARK: - UserResult
struct UserResult: Decodable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileImage
struct ProfileImage: Decodable {
    let small, medium, large: String
}
