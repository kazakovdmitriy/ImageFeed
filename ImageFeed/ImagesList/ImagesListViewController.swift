//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 28.03.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!

    // MARK: - Private Properties
    private let imageListService = ImagesListService.shared
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private var photos: [Photo] = []
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                
                guard let self = self else { return }
                
                updateTableViewAnimated()
            }
        imageListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            viewController.imageURLString = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender) // 7
        }
    }

    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        cell.delegate = self
        
        let photo = photos[indexPath.row]
        
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        let placeholder = UIImage(named: "stub")
        cell.cellImageOutlet.kf.indicatorType = .activity
        cell.cellImageOutlet.kf.setImage(with: url, placeholder: placeholder, options: []) { [weak self] result in
            switch result {
            case .success:
                if let createdDate = photo.createdAt {
                    cell.dateLabelOutlet.text = self?.dateFormatter.string(from: createdDate)
                } else {
                    cell.dateLabelOutlet.text = ""
                }
                
                let likeImage: UIImage? = photo.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NoActiveLike")
                cell.likeButtonOutlet.setImage(likeImage, for: .normal)
                
                cell.cellImageOutlet.removeAnimation()
            case .failure(let error):
                print("[ImageListViewController]: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func updateTableViewAnimated() {
        let currCount = photos.count
        let newCount = imageListService.photos.count
        
        photos = imageListService.photos
        
        if currCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (currCount..<newCount).map { i in IndexPath(row: i, section: 0) }
                tableView.insertRows(at: indexPaths, with: .bottom)
            } completion: { _  in }
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("Ошибка изменения лайка: \(error.localizedDescription)")
                UIBlockingProgressHUD.dismiss()
                self.showError()
            }
        }
        cell.setIsLiked(isLiked: photo.isLiked)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, 
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if indexPath.row + 1 == imageListService.photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UIAlertController
extension ImagesListViewController {
    private func showError() {
        
        let alertController = UIAlertController(title: "Что-то пошло не так.",
                                                message: "Не удалось поставить лайк фото.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ок", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
