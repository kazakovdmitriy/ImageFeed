//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Дмитрий on 07.05.2024.
//

import ProgressHUD
import UIKit

protocol AuthViewControllerDelegate: AnyObject{
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard 
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Что-то пошло не так",
                                                message: "Не удалось войти в систему",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            
            switch result {
            case .success(_):
                self.delegate?.didAuthenticate(self)
            case .failure(_):
                showErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
