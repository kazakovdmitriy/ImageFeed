//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 12.04.2024.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private var fullScreenImageOutlet: UIImageView!

    // MARK: - Public Properties
    var imageURLString: String?

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.5
        fullScreenImageOutlet.contentMode = .scaleAspectFit
        
        loadImage()
    }

    // MARK: - IB Actions
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [fullScreenImageOutlet.image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    // MARK: - Private Methods
    private func loadImage() {
        guard let imageURLString = imageURLString, let url = URL(string: imageURLString) else { return }
        
        let placeholderImage = UIImage(named: "full_screen_stub")
        
        UIBlockingProgressHUD.show()
        fullScreenImageOutlet.kf.indicatorType = .activity
        fullScreenImageOutlet.setImageWithPlaceholder(url: url,
                                                      placeholder: placeholderImage,
                                                      placeholderContentMode: .center,
                                                      contentMode: .scaleAspectFit)
        { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                self.fullScreenImageOutlet.image = value.image
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("[SingleImageViewController]: \(error.localizedDescription)")
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(hScale, vScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        fullScreenImageOutlet.frame.size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        scrollView.contentSize = fullScreenImageOutlet.frame.size
        
        centerImage()
    }
    
    private func centerImage() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        fullScreenImageOutlet.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                               y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    
    
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullScreenImageOutlet
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

// MARK: - UIAllertController
extension SingleImageViewController {
    private func showError() {
        let alertController = UIAlertController(title: "Что-то пошло не так. Попробовать ещё раз?",
                                                message: "Не удалось загрузить фото.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)
        present(alertController, animated: true)
    }
}
