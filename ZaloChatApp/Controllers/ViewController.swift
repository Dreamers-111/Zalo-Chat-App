//
//  ViewController.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpNavigation()
        swiping()
        
        view.addSubview(logoView)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    func setUpNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.76, blue: 0.49, alpha: 1.00)
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.backButtonTitle = "Trang chủ"
    }
    
    @objc private func swiping() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let swipingController = SwipingViewController(collectionViewLayout: layout)
        swipingController.view.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height / 1.25)
        view.addSubview(swipingController.view)
        self.addChild(swipingController)
        swipingController.didMove(toParent: self)
    }
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .mainColor
        button.setTitleColor(.mainColor, for: .focused)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    @objc private func didTapLogin() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    @objc private func didTapRegister() {
//        let vc = RegisterEnterUserInfoViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.00)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -230),
            logoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 150),
            logoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -150),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }
}
    
