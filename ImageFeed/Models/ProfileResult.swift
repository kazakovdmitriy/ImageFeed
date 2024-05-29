//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Дмитрий on 23.05.2024.
//

import Foundation

// MARK: - ProfileResult
struct ProfileResult: Codable {
    let id: String
    let username, 
        firstName,
        lastName: String
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}
