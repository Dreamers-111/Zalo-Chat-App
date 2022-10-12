//
//  RegisterEnterUserInfoViewController.swift
//  Chat-app
//
//  Created by Phạm Văn Nam on 08/10/2022.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    let gender = ["Nam", "Nữ"]
    let ctlbnf : CGFloat = 20, ctleftright : CGFloat = 10, cttop : CGFloat = 10
    
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

    private let genderfield: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Nhập giới tính của bạn..."
        field.addBottomBorder()
        return field
    }()
    

    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .white
        pickerView.selectRow(0, inComponent: 0, animated: true)
        return pickerView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleToFill
        imageView.layer.masksToBounds = true
        imageView.tintColor = UIColor(red: 0.06, green: 0.76, blue: 0.49, alpha: 1.00)
        return imageView
    }()

    private let userNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "Nhập tên người dùng..."
        field.addBottomBorder()
        field.clearButtonMode = .always
        return field
    }()

    private let labelandButtonStackView: UIStackView = {
        let stackView = UIStackView()
        let label = UILabel()
        let button = UIButton()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)

        // (Add some test data, a little spacing, and the background color
        // make the labels easier to see visually.)
        label.font = .systemFont(ofSize: 14,weight: .regular)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        let labelText = NSMutableAttributedString.init(string: "Tiếp tục nghĩa là bạn đồng ý với các điều khoản sử dụng của chúng tôi")
        labelText.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray],
                                range: NSMakeRange(0, 33))
        labelText.setAttributes([NSAttributedString.Key.foregroundColor:   UIColor(red: 0.53, green: 0.87, blue: 0.74, alpha: 1.00)],
                                range: NSMakeRange(33, 36))
        label.attributedText = labelText
        label.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 4,constant: 20).isActive = true
        
        button.setImage(UIImage(systemName: "arrow.right",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(red: 0.06, green: 0.76, blue: 0.49, alpha: 1.00)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tên tài khoản:"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Giới tính:"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        return label
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
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "Nhập email..."
        field.addBottomBorder()
        field.clearButtonMode = .always
        
        return field
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
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.placeholder = "Nhập mật khẩu..."
        field.addBottomBorder()
        field.clearButtonMode = .always
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ngày sinh:"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.sizeToFit()
        return label
    }()
    
    private let dayField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Nhập ngày sinh của bạn..."
        field.addBottomBorder()
        field.datePicker(target: self,
                         doneAction: #selector(doneAction),
                         cancelAction: #selector(cancelAction),
                         datePickerMode: .date)
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Connect data:
        pickerView.delegate = self
        pickerView.dataSource = self
        genderfield.inputView = pickerView
        
        userNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        // Add subviews
        
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailField)
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordField)
        contentView.addSubview(nameLabel)
        contentView.addSubview(userNameField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderfield)
        contentView.addSubview(dateLabel)
        contentView.addSubview(dayField)
        contentView.addSubview(labelandButtonStackView)
        
        imageView.isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true

        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func registerButtonTapped() {
        userNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        dayField.resignFirstResponder()
        genderfield.resignFirstResponder()
        
        guard let userName = userNameField.text,
            let userGender = genderfield.text,
            let userBirthDay = dayField.text,
            let email = emailField.text,
            let password = passwordField.text,
            !userName.isEmpty,
            !userGender.isEmpty,
            !userBirthDay.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            password.count >= 6
             else {
                alertUserLoginError()
                return
        }
        
        let alert = UIAlertController(title: "Xác nhận sử dụng email " + (emailField.text ?? ""), message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { action in
            
            RegisterViewModel.shared.registerUser(with: User(userID: "", userName: userName, userEmail: email, userBitrhDay: userBirthDay, userGender: userGender, userStatus: true), password: password)
                
        }))
        alert.addAction(UIAlertAction(title:"Huỷ bỏ",
                                      style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
 
   
        
    }
    
    func alertUserLoginError(message: String = "Vui lòng nhập đầy đủ thông tin") {
        let alert = UIAlertController(title: message,
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Đồng ý",
                                      style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

    // datepicker
    @objc func cancelAction() {
       self.dayField.resignFirstResponder()
    }

    @objc func doneAction() {
       if let datePickerView = self.dayField.inputView as? UIDatePicker {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd/MM/yyyy"
           let dateString = dateFormatter.string(from: datePickerView.date)
           self.dayField.text = dateString
           
           print(datePickerView.date)
           print(dateString)
           
           self.dayField.resignFirstResponder()
       }
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    private func addConstraints(){
        
        // Add
        let constraints = [
            scrollView.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo:  scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: cttop),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/4),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: cttop),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor,constant: cttop),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor,constant: ctlbnf),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor,constant: cttop),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            
            nameLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor,constant: ctlbnf),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            userNameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: cttop),
            userNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            userNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            genderLabel.topAnchor.constraint(equalTo: userNameField.bottomAnchor,constant: ctlbnf),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            genderfield.topAnchor.constraint(equalTo: genderLabel.bottomAnchor,constant: cttop),
            genderfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            genderfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            dateLabel.topAnchor.constraint(equalTo: genderfield.bottomAnchor,constant: ctlbnf),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            dayField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,constant: cttop),
            dayField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: ctleftright),
            dayField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -ctleftright),
            
            labelandButtonStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,constant: ctleftright),
            labelandButtonStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,constant: -ctleftright),
//            labelandButtonStackView.topAnchor.constraint(
//                equalTo: dayField.bottomAnchor, constant: 30),
            labelandButtonStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -10),
            labelandButtonStackView.heightAnchor.constraint(equalTo: dayField.heightAnchor, multiplier: 1.5)
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
        self.addKeyboardObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents (in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }

    func pickerView(_ pickerView:UIPickerView,didSelectRow row: Int,inComponent component: Int){
        genderfield.text = gender[row]
        genderfield.resignFirstResponder()
    }
    
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
       textField.resignFirstResponder()

       return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text == nil {return true}
        if (textField == emailField && textField.text!.isEmail) {
            return true
        }
        else if textField == emailField {
            let alert = UIAlertController(title: "Hãy nhập đúng email",
                                          message: "",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Đồng ý",
                                          style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return false
        }
        return true
    }
}
