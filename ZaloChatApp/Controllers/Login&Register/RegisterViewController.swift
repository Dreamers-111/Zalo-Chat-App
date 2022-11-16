//
//  RegisterEnterUserInfoViewController.swift
//  Chat-app
//
//  Created by Phạm Văn Nam on 08/10/2022.
//

import FirebaseAuth
import UIKit

class RegisterViewController: UIViewController {
    let gender = ["Nam", "Nữ"]
    let ctlbnf: CGFloat = 20, ctleftright: CGFloat = 20, cttop: CGFloat = 10
    
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
        imageView.image = UIImage(named: "addAvt")
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let userNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nhập tên người dùng..."
        field.setFieldLoginAndRegister()
        return field
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.keyboardType = .emailAddress
        field.placeholder = "Nhập email..."
        field.setFieldLoginAndRegister()
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nhập mật khẩu..."
        field.setFieldLoginAndRegister()
        field.clearButtonMode = .always
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let genderField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Nhập giới tính của bạn..."
        field.setFieldLoginAndRegister()
        field.clearButtonMode = .never
        return field
    }()
    
    private let genderPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.selectRow(0, inComponent: 0, animated: true)
        return pickerView
    }()
    
    private let genderPickViewToolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        let toolBarAppearance = UIToolbarAppearance()
        toolBarAppearance.backgroundColor = .white
        toolBar.standardAppearance = toolBarAppearance
        toolBar.tintColor = .systemGreen
        toolBar.sizeToFit()
        return toolBar
    }()
    
    private let birthdayField: UITextField = {
        let field = UITextField()
        field.placeholder = "Nhập ngày sinh của bạn..."
        field.setFieldLoginAndRegister()
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Đăng ký", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = UIColor.mainColor
        button.layer.cornerRadius = 15
        // Shadow Color
        button.layer.shadowColor = UIColor.mainColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 1
        button.layer.masksToBounds = false
        return button
    }()
    
    private let alertLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        let labelText = NSMutableAttributedString(string: "Tiếp tục nghĩa là bạn đồng ý với các điều khoản sử dụng của chúng tôi")
        labelText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray],
                                range: NSMakeRange(0, 33))
        labelText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.mainColor],
                                range: NSMakeRange(33, 36))
        label.attributedText = labelText
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // genderField:
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        
        emailField.delegate = self
        passwordField.delegate = self
        userNameField.delegate = self
        genderField.delegate = self
        birthdayField.delegate = self
        
        view.addSubview(scrollView)
        // Add subviews
        
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(emailField)
        contentView.addSubview(passwordField)
        contentView.addSubview(userNameField)
        contentView.addSubview(genderField)
        contentView.addSubview(birthdayField)
        contentView.addSubview(registerButton)
        contentView.addSubview(alertLabel)
        
        setupProfileImageTapGesture()
        setupGenderField()
        setupBirthdatField()
        setupButtonTarget()
    }
    
    private func setupGenderField() {
        let cancelToolBarButton = UIBarButtonItem(title: "Hủy", style: .done, target: self, action: #selector(cancelGenderField))
        cancelToolBarButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 21, weight: .regular)], for: .normal)
        let doneToolBarButton = UIBarButtonItem(title: "Xác nhận", style: .done, target: self, action: #selector(doneGenderField))
        doneToolBarButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 21, weight: .regular)], for: .normal)
        
        genderPickViewToolbar.setItems([
            cancelToolBarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                            target: nil, action: nil),
            doneToolBarButton,
        ],
        animated: true)
        genderPickViewToolbar.isUserInteractionEnabled = true
        genderField.inputView = genderPickerView
        genderField.inputAccessoryView = genderPickViewToolbar
    }
    
    private func setupBirthdatField() {
        birthdayField.datePicker(target: self,
                                 doneAction: #selector(doneAction),
                                 cancelAction: #selector(cancelAction),
                                 datePickerMode: .date)
    }
    
    private func setupProfileImageTapGesture() {
        imageView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    private func setupButtonTarget() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func registerButtonTapped() {
        userNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        birthdayField.resignFirstResponder()
        genderField.resignFirstResponder()
        
        guard let name = userNameField.text,
              let gender = genderField.text,
              let birthday = birthdayField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !name.isEmpty,
              !gender.isEmpty,
              !birthday.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6
        else {
            alertUserLoginError()
            return
        }
        /// Nếu imageView.image là hình ảnh mặc địch, thì profileImage là nil, còn không thì là imageView.image
        ///  imageView.image luôn khác nil nên có thể sử dụng !
        let profileImage = imageView.image!.isEqualToImage(UIImage(named: "addAvt")!) ? nil : imageView.image
        
        let newUser = User(id: "",
                           name: name,
                           email: email,
                           gender: gender,
                           birthday: birthday,
                           profilePictureUrl: "",
                           isActive: true)
        
        let alert = UIAlertController(title: "Xác nhận sử dụng email " + email, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { _ in
            
            RegisterViewModel.shared.registerUser(with: newUser, password: password, profileImage: profileImage)
                
        }))
        alert.addAction(UIAlertAction(title: "Huỷ bỏ",
                                      style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func alertUserLoginError(message: String = "Vui lòng nhập đầy đủ thông tin") {
        let alert = UIAlertController(title: message,
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đồng ý",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // datepicker
    @objc func cancelAction() {
        birthdayField.resignFirstResponder()
    }

    @objc func doneAction() {
        if let datePickerView = birthdayField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            birthdayField.text = dateString
            birthdayField.resignFirstResponder()
        }
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    @objc private func cancelGenderField() {
        genderField.resignFirstResponder()
    }

    @objc private func doneGenderField() {
        let selectedIndex = genderPickerView.selectedRow(inComponent: 0)
        genderField.text = gender[selectedIndex]
        genderField.resignFirstResponder()
    }

    private func addConstraints() {
        // Add
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
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 4),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            emailField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 25),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: cttop),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            userNameField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: cttop),
            userNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            userNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            genderField.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: cttop),
            genderField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            genderField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            birthdayField.topAnchor.constraint(equalTo: genderField.bottomAnchor, constant: cttop),
            birthdayField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            birthdayField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            registerButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 10),
            registerButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -10),
            registerButton.topAnchor.constraint(
                equalTo: birthdayField.bottomAnchor, constant: 30),
            registerButton.heightAnchor.constraint(equalTo: birthdayField.heightAnchor, multiplier: 1.1),
            
            alertLabel.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            alertLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            alertLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: alertLabel.bottomAnchor),
        ]

        // Activate
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addConstraints()
        imageView.layer.cornerRadius = imageView.frame.height / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Ảnh đại diện",
                                            message: "Bạn muốn chọn ảnh đại diện bằng cách:",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Huỷ bỏ",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Chụp ảnh",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()

                                            }))
        actionSheet.addAction(UIAlertAction(title: "Tải ảnh",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()

                                            }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            userNameField.becomeFirstResponder()
        }
        else if textField == userNameField {
            genderField.becomeFirstResponder()
        }
        else if textField == genderField {
            birthdayField.becomeFirstResponder()
        }
        else if textField == birthdayField {
            // do nothing.
        }

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == emailField, !(textField.text ?? "").isEmpty, !textField.text!.isEmail {
            let alert = UIAlertController(title: "Hãy nhập đúng email",
                                          message: "",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Đồng ý",
                                          style: .cancel))
            present(alert, animated: true)
            return false
        }
        return true
    }
}
