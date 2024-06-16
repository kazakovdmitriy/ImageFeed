//
//  ImageViewTest.swift
//  ImageFeedTests
//
//  Created by Дмитрий on 13.06.2024.
//

@testable import ImageFeed
import XCTest

final class ImageViewTest: XCTestCase {
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        // Given
        let presenter = ImagesPresenterSpy()
        let imageView = ImagesListViewController(presenter: presenter)
        
        // When
        _ = imageView.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
        
    func testViewDidLoad_CallsServiceFetchPhotosNextPage() {
        // Given
        let imageListService = ImageListServiceSpy()
        let presenter = ImagesListPresenter(imageListService: imageListService)
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(imageListService.fetchPhotosNextPageCalled)
    }
    
    
    func testDidTapLikeButton_CallsServiceChangeLike() {
        // Given
        let imageListService = ImageListServiceSpy()
        let presenter = ImagesListPresenter(imageListService: imageListService)
        presenter.photos = [Photo(id: "1", size: CGSize(), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        
        // When
        presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertTrue(imageListService.changeLikeCalled)
    }
}

// MARK: - Mock
final class ImageListViewControllerSpy: ImagesListViewProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    var updateTableViewCalled = false
    
    func updateTableView() {
        updateTableViewCalled = true
    }
    
    var showErrorCalled = false
    
    func showError(message: String) {
        showErrorCalled = true
    }
}

final class ImageListServiceSpy: ImageListServiceProtocol {
    
    var photos: [ImageFeed.Photo] = []
    
    var fetchPhotosNextPageCalled = false
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    var changeLikeCalled = false
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class ImagesPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLikeButton(at indexPath: IndexPath) {}
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {}
    func numberOfRows() -> Int { return 0 }
    func willDisplayCell(at indexPath: IndexPath) {}
}
