//
//  Created by Phan Tâm Như on 08/10/2022.
//

import FirebaseAuth
import GoogleSignIn
import UIKit

class LoginViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()

    private let contentView: UIView = {
        var contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "login")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nhập email..."
        field.setFieldLoginAndRegister()
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nhập mật khẩu..."
        field.setFieldLoginAndRegister()
        field.isSecureTextEntry = true
        field.clearButtonMode = .always
        return field
    }()
    
    private let guideLabel1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Chào mừng bạn quay trở lại"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let guideLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hoặc"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Đăng nhập", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = UIColor.subColor
        button.layer.cornerRadius = 15
        // Shadow Color
        button.layer.shadowColor = UIColor.subColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 1
        button.layer.masksToBounds = false
        return button
    }()
    
    private let googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.layer.cornerRadius = 15
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(guideLabel1)
        contentView.addSubview(emailField)
        contentView.addSubview(guideLabel2)
        contentView.addSubview(passwordField)
        contentView.addSubview(loginButton)
        contentView.addSubview(guideLabel2)
        contentView.addSubview(googleSignInButton)
        
        contentView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
    }

    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty, !password.isEmpty,
              password.count >= 6
        else {
            alertUserLoginError()
            return
        }
        
        LoginViewModel.shared.firebaseSignIn(with: email, password: password)
    }

    @objc private func googleSignInButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        LoginViewModel.shared.googleSignIn()
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "",
                                      message: "Vui lòng nhập đúng thông tin",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đồng ý",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func addConstraints() {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 4),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            guideLabel1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            guideLabel1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailField.topAnchor.constraint(equalTo: guideLabel1.bottomAnchor, constant: 20),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 28),
            loginButton.heightAnchor.constraint(equalTo: passwordField.heightAnchor),
            
            guideLabel2.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            guideLabel2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            googleSignInButton.topAnchor.constraint(equalTo: guideLabel2.bottomAnchor, constant: 10),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addConstraints()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}
