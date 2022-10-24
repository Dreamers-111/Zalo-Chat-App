//
//  Login&RegisterViewController.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import UIKit

class Login_RegisterViewController: UIViewController {
      
    private let loginButton: UIButton = {
        var filled = UIButton.Configuration.borderless()
        filled.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let button = UIButton(configuration: filled, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Đăng nhập", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.tintColor = .black
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 15
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        return button
    }()
    
    private let registerButton: UIButton = {
        var filled = UIButton.Configuration.borderless()
        filled.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let button = UIButton(configuration: filled, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Đăng ký", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.90, green: 0.00, blue: 0.21, alpha: 1.00)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = false
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        var buttonStackView = UIStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fill
        return buttonStackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        setUpNavBar()
        swiping()
        
        buttonStackView.addArrangedSubview(loginButton)
        buttonStackView.addArrangedSubview(registerButton)
        
        view.addSubview(buttonStackView)
    }
      
    private func setUpNavBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.backButtonTitle = "Trang chủ"
    }
      
    private func swiping() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let swipingController = SwipingCollectionViewController(collectionViewLayout: layout)
        swipingController.view.frame = CGRectMake(0, 0, view.frame.width, view.frame.height / 1.25)
        view.addSubview(swipingController.view)
        addChild(swipingController)
        swipingController.didMove(toParent: self)
    }
      
    @objc private func didTapLogin() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
      
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
      
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 55)
        ])
    }
}
