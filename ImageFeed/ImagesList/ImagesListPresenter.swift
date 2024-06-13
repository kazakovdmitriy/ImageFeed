//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий on 13.06.2024.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get set }
    
    func viewDidLoad()
    func didTapLikeButton(at indexPath: IndexPath)
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath)
    func numberOfRows() -> Int
    func willDisplayCell(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    
    private let imageListService = ImagesListService.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                
                self.updatePhotos()
            }
        
        imageListService.fetchPhotosNextPage()
    }
    
    func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let url = URL(string: photo.thumbImageURL) {
            let placeholder = UIImage(named: "stub")
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder, options: []) { result in
                switch result {
                case .success: break
                case .failure(let error):
                    print("[ImagesListPresenter]: \(error.localizedDescription)")
                }
            }
        }
        
        if let createdDate = photo.createdAt {
            cell.dateLabel.text = self.dateFormatter.string(from: createdDate)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage: UIImage? = photo.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NoActiveLike")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.likeButton.accessibilityIdentifier = photo.isLiked ? "ActiveLike" : "NoActiveLike"
    }
    
    func didTapLikeButton(at indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                UIBlockingProgressHUD.dismiss()
                self.view?.updateTableView()
            case .failure(let error):
                print("Ошибка изменения лайка: \(error.localizedDescription)")
                UIBlockingProgressHUD.dismiss()
                self.view?.showError(message: "Не удалось поставить лайк фото.")
            }
        }
    }
    
    func numberOfRows() -> Int {
        return photos.count
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row + 1 == imageListService.photos.count &&
            !ProcessInfo.processInfo.arguments.contains("UITEST") {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    private func updatePhotos() {
        self.photos = imageListService.photos
        view?.updateTableView()
    }
    
}
