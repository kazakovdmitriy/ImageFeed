//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Дмитрий on 30.05.2024.
//

@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    
    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
    
    func testFetchManyPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 15)
        
        XCTAssertEqual(service.photos.count, 10)
    }
    
    func testFetchPhotosTwoTimes() {
        let service = ImagesListService.shared
        
        let firstExpectation = self.expectation(description: "Wait for First Notification")
        var observer1: NSObjectProtocol?
        observer1 = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                firstExpectation.fulfill()
                if let observer1 = observer1 {
                    NotificationCenter.default.removeObserver(observer1)
                }
            }
        
        service.fetchPhotosNextPage()
        wait(for: [firstExpectation], timeout: 15)
        
        let secondExpectation = self.expectation(description: "Wait for Second Notification")
        var observer2: NSObjectProtocol?
        observer2 = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                secondExpectation.fulfill()
                if let observer2 = observer2 {
                    NotificationCenter.default.removeObserver(observer2)
                }
            }
        
        service.fetchPhotosNextPage()
        wait(for: [secondExpectation], timeout: 15)
        
        XCTAssertEqual(service.photos.count, 20)
    }
}
