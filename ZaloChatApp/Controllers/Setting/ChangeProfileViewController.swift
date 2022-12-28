//
//  ChangeProfileViewController.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 09/12/2022.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Kingfisher
import UIKit
import JGProgressHUD


class ChangeProfileViewController: UIViewController {
    
    private let db = DatabaseManager.shared

    // MARK: Listeners

    private var currentUserListeners: ListenerRegistration?

    // MARK: Parameters - Data

    private var currentUser = User()
    
    let gender = ["Nam", "Nữ"]
    let ctlbnf: CGFloat = 20, ctleftright: CGFloat = 30, cttop: CGFloat = 10
    
    // MARK: Parameters - UIKit
    
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

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.text = "Họ và tên:"
        label.sizeToFit()
        return label
    }()
    
    private let userNameField: UITextField = {
        let field = UITextField()
        field.setFieldLoginAndRegister()
        field.layer.cornerRadius = 4
        return field
    }()

    private let genderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.text = "Giới tính:"
        label.sizeToFit()
        return label
    }()
    
    private let genderField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setFieldLoginAndRegister()
        field.clearButtonMode = .never
        field.layer.cornerRadius = 4
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
    
    private let birthdayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        label.text = "Ngày sinh:"
        label.sizeToFit()
        return label
    }()
    private let birthdayField: UITextField = {
        let field = UITextField()
        field.setFieldLoginAndRegister()
        field.layer.cornerRadius = 4
        return field
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Lưu", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = UIColor.mainColor
        button.layer.cornerRadius = 15
        return button
    }()
    
    // MARK: Deinit

    deinit {
        if currentUserListeners?.remove() != nil {
            currentUserListeners = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // genderField:
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
    
        userNameField.delegate = self
        genderField.delegate = self
        birthdayField.delegate = self
        
        view.addSubview(scrollView)
        // Add subviews

        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(userNameField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderField)
        contentView.addSubview(birthdayLabel)
        contentView.addSubview(birthdayField)
        contentView.addSubview(saveButton)
        
        
        startListeningForCurrentUser()
        
        setupProfileImageTapGesture()
        setupGenderField()
        setupBirthdatField()
        
        //button action
        
        saveButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)

    }
    private func loadData() {
        userNameField.text = currentUser.name
        genderField.text = currentUser.gender
        birthdayField.text = currentUser.birthday
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
    

    @objc private func registerButtonTapped() {
        userNameField.resignFirstResponder()
        birthdayField.resignFirstResponder()
        genderField.resignFirstResponder()
        
        guard let name = userNameField.text,
              let gender = genderField.text,
              let birthday = birthdayField.text,
              !name.isEmpty,
              !gender.isEmpty,
              !birthday.isEmpty
        else {
            alertUserSaveError()
            return
        }
        
        let alert = UIAlertController(title: "Xác nhận sử dụng thay đổi", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { _ in
            
            // Lấy RegisterViewController hiện tại hiển thị
            let vc = self
            
            // hiển thị spinner đang tải lên vc
            let spinner = JGProgressHUD(style: .dark)
            spinner.show(in: vc.view)
            
            let data = self.imageView.image!.pngData()
            let fileName = self.currentUser.profilePictureFilename
            StorageManager.shared.uploadMediaItem(withData: data!, fileName: fileName,
                                                  location: .users_pictures) { result in
                switch result {
                    case .success(let downloadURL):
                        DatabaseManager.shared.updateUser(withId: self.currentUser.id,
                                                          data: [
                                                                    "name": self.userNameField.text!,
                                                                      "gender": self.genderField.text!,
                                                                      "birthday": self.birthdayField.text!,
                                                                      "profile_picture_url": downloadURL]) { success in
                            guard success else {
                                print("failed to update user \(self.currentUser.id) with profile picture url.")
                                let alert = UIAlertController(title: "Không thể lưu thay đổi",
                                                              message: "",
                                                              preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Đồng ý",
                                                              style: .cancel))
                                vc.present(alert, animated: true)
                                DispatchQueue.main.async {
                                    spinner.dismiss(animated: true)
                                }
                                return
                            }
                              DatabaseManager.shared.updateConservation(withId: self.currentUser.id, newName: self.userNameField.text!, url:  downloadURL) { success in
                              guard success else {
                                  print("lỗi update conversations")
                                  return
                                }
                              }

                              Defaults.currentUser[.profilePictureUrl] = downloadURL
                              Defaults.currentUser[.name] = self.userNameField.text!
                              let alert = UIAlertController(title: "Lưu thay đổi thành công",
                                                            message: "",
                                                            preferredStyle: .alert)
                              alert.addAction(UIAlertAction(title: "Đồng ý",
                                                            style: .cancel))
                              vc.present(alert, animated: true)
                              DispatchQueue.main.async {
                                  spinner.dismiss(animated: true)
                              }
                        }
                    
                    case .failure(let error):
                        print("\(error)")
                        let alert = UIAlertController(title: "Không thể lưu sự thay đổi",
                                                      message: "",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Đồng ý",
                                                      style: .cancel))
                        vc.present(alert, animated: true)
                        DispatchQueue.main.async {
                            spinner.dismiss(animated: true)
                        }
                    }
                    Defaults.currentUser[.name] = self.userNameField.text!
                    
                    let alert = UIAlertController(title: "Chỉnh sửa hồ sơ thành công",
                                                  message: "",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Đồng ý",
                                                  style: .cancel))
            }
                
        }))
        alert.addAction(UIAlertAction(title: "Huỷ bỏ",
                                      style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func alertUserSaveError(message: String = "Vui lòng nhập đầy đủ thông tin") {
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
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1 / 4.5),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            
            userNameField.heightAnchor.constraint(equalToConstant: 40),
            genderField.heightAnchor.constraint(equalToConstant: 40),
            birthdayField.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            
            userNameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            userNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            userNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            genderLabel.topAnchor.constraint(equalTo: userNameField.bottomAnchor, constant: 10),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            
            genderField.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 10),
            genderField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            genderField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            birthdayLabel.topAnchor.constraint(equalTo: genderField.bottomAnchor, constant: 10),
            birthdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            
            birthdayField.topAnchor.constraint(equalTo: birthdayLabel.bottomAnchor, constant: 10),
            birthdayField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ctleftright),
            birthdayField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ctleftright),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(
                equalTo: birthdayField.bottomAnchor, constant: 30),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: saveButton.bottomAnchor),
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
    
    private func updateProfileImage() {
        imageView.kf.setImage(with: URL(string: currentUser.profilePictureUrl),
                                                placeholder: UIImage(named: "default_avatar"))
    }
    
    private func startListeningForCurrentUser() {
        guard let currentUserId = Defaults.currentUser[.id] else {
            print("Thất bại lắng nghe người dùng hiện tại")
            return
        }

        currentUserListeners = db.listenForUser(with: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUser = user
                DispatchQueue.main.async {
                    self?.updateProfileImage()
                    self?.loadData()
                }
            case .failure(let error):
                print("Thất bại lắng nghe người dùng hiện tại: \(error)")
            }
        }
    }
}

extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Ảnh đại diện",
                                            message: "Bạn muốn chọn ảnh đại diện mới bằng cách:",
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

extension ChangeProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
}

extension ChangeProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField {
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
}
