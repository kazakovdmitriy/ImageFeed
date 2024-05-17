//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Дмитрий on 14.05.2024.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken, tokenType, scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
