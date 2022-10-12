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
        contentView.clipsToBounds = true
        return contentView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.tintColor = UIColor(red: 0.06, green: 0.76, blue: 0.49, alpha: 1.00)
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "Nhập email..."
        field.addBottomBorder()
        field.clearButtonMode = .always
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "Nhập mật khẩu..."
        field.addBottomBorder()
        field.clearButtonMode = .always
        field.keyboardType = .default
        return field
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Email:"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Password:"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let googleSignInButton: GIDSignInButton = {
        let btn = GIDSignInButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        // Add subviews
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailField)
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordField)
        contentView.addSubview(loginButton)
        contentView.addSubview(googleSignInButton)
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
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1 / 4),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 50),
            
            googleSignInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            googleSignInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            googleSignInButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 50),
        ]

        // Activate
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
