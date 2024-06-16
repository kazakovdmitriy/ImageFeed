//
//  ProfileViewTest.swift
//  ImageFeedTests
//
//  Created by Дмитрий on 12.06.2024.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTest: XCTestCase {
    func testPresenterMakeLabel() {
        // given
        
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        
        let profileViewPresenter = ProfileViewPresenter(logoutService: logoutService, profileService: profileService, profileImageService: profileImageService)
        
        // when
        let testLabel = profileViewPresenter.makeLabel(text: "test", fontSize: 15, color: UIColor.ypBlack, fontStyle: .regular)
        
        // then
        XCTAssertEqual(testLabel.text, "test")
        XCTAssertEqual(testLabel.textColor, UIColor.ypBlack)
    }
    
    func testUpdateProfileInfo_FillProfileCalled() {
        // Given
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        
        let profile = Profile(username: "testuser", name: "Test User", loginName: "", bio: "This is a bio")
        profileService.profile = profile
        
        let profileViewPresenter = ProfileViewPresenter(logoutService: logoutService, profileService: profileService, profileImageService: profileImageService)
        let view = ProfileViewControllerMock(presenter: profileViewPresenter)
        profileViewPresenter.view = view
        
        // When
        profileViewPresenter.updateProfileInfo()
        
        // Then
        XCTAssertTrue(view.fillProfileCalled)
        XCTAssertEqual(view.profile?.name, profile.name)
        XCTAssertEqual(view.profile?.username, profile.username)
        XCTAssertEqual(view.profile?.bio, profile.bio)
    }
    
    func testViewControllerCallsUpdateProfile() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.updateProfileInfoCalls)
    }
    
    func testGetAvatarImageURL_ReturnsCorrectURL() {
        // given
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        
        let profileViewPresenter = ProfileViewPresenter(logoutService: logoutService, profileService: profileService, profileImageService: profileImageService)
        
        let urlString = "https://example.com/avatar.jpg"
        profileImageService.avatarURL = urlString
        
        // when
        let url = profileViewPresenter.getAvatarImageURL()
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, urlString)
    }
    
    func testMakeLogoutAlert() {
        // given
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        
        let profileViewPresenter = ProfileViewPresenter(logoutService: logoutService, profileService: profileService, profileImageService: profileImageService)
        
        // when
        let alertController = profileViewPresenter.makeLogoutAlert()
        
        // Then
        XCTAssertEqual(alertController.title, "Пока, пока!")
        XCTAssertEqual(alertController.message, "Уверены что хотите выйти?")
        XCTAssertEqual(alertController.actions.count, 2)
        
        let yesAction = alertController.actions[0]
        XCTAssertEqual(yesAction.title, "Да")
        XCTAssertEqual(yesAction.style, .default)
        
        let noAction = alertController.actions[1]
        XCTAssertEqual(noAction.title, "Нет")
        XCTAssertEqual(noAction.style, .default)
    }
}

// MARK: - Mocks
final class ProfileViewControllerMock: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol
    var fillProfileCalled = false
    var profile: Profile?
    
    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
    }
    
    func fillProfile(profile: Profile) {
        fillProfileCalled = true
        self.profile = profile
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var updateProfileInfoCalls: Bool = false
    
    func makeLogoutAlert() -> UIAlertController {
        return UIAlertController()
    }
    
    func makeLabel(text: String, fontSize: CGFloat, color: UIColor, fontStyle: ImageFeed.FontStyle) -> UILabel {
        return UILabel()
    }
    
    func getAvatarImageURL() -> URL? {
        return nil
    }
    
    func updateProfileInfo() {
        updateProfileInfoCalls = true
    }
    
    
}

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?
}

final class ProfileLogoutServiceMock: ProfileLogoutServiceProtocol {
    func logout() {}
}
