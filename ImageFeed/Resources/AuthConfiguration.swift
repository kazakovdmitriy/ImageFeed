//
//  Constants.swift
//  ImageFeed
//
//  Created by Дмитрий on 07.05.2024.
//

import Foundation

private enum AuthConstants {
    static let accessKey = "g5KZBv93MU_RxUaulqnJ_p1G8dxCMTKRZAuiRxpuwsI"
    static let secretKey = "DHcjxkDT1PeTA8whKhI85MdK0B2RVCb8MXfObqHa9Q8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}


struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(
            accessKey: AuthConstants.accessKey,
            secretKey: AuthConstants.secretKey,
            redirectURI: AuthConstants.redirectURI,
            accessScope: AuthConstants.accessScope,
            authURLString: AuthConstants.unsplashAuthorizeURLString)
    }
}
