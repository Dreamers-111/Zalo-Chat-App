//
//  RegisterViewModel.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 12/10/2022.
//

import FirebaseAuth
import Foundation
import JGProgressHUD

/// Manager object to read and write data to real time firebase database
final class RegisterViewModel {
    private init() {}

    /// Shared instance of class
    static let shared = RegisterViewModel()

    private func getCurrentRegisterVC() -> RegisterViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }

        // MainTabBarController
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return nil }

        // UINavigationController của Login_RegisterViewController
        guard let nav = rootViewController.presentedViewController as? UINavigationController else { return nil }

        // RegisterViewController
        return nav.topViewController as? RegisterViewController
    }

    func registerUser(with user: User, password: String, profileImage: UIImage?) {
        // Lấy RegisterViewController hiện tại hiển thị
        guard let vc = getCurrentRegisterVC() else {
            print("Lấy RegisterViewController hiện đang hiển thị không thành công.")
            return
        }

        // hiển thị spinner đang tải lên vc
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: vc.view)

        // Đăng ký người dùng với email và password, nếu email đã được sử dụng để đăng ký tài khoản khác, hoặc email đã được sử dụng để đăng nhập qua Google, thì người dùng sẽ không đăng nhập được
        FirebaseAuth.Auth.auth().createUser(withEmail: user.email, password: password) { authResult, error in
            guard let result = authResult, error == nil else {
                print("Đã đăng ký thất bại, user với email \(user.email).", error?.localizedDescription ?? "")
                let alert = UIAlertController(title: "Email đã sử dụng, xin mời sử dụng email khác",
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
            // Đăng ký thành công người dùng với email và password
            var user = user
            user.id = result.user.uid
            // Sau khi đăng ký thành công, thực hiện ghi người dùng vào database
            DatabaseManager.shared.insertUser(with: user) { success in
                guard success else {
                    print("failed to insert user \(user.id) into database")
                    DispatchQueue.main.async {
                        spinner.dismiss(animated: true)
                    }
                    return
                }
                // Ghi người dùng vào database thành công
                // Sau khi ghi người dùng thành công, thực hiện tải hình ảnh hồ sơ nếu người dùng có chọn ảnh
                if let image = profileImage,
                   let data = image.pngData()
                {
                    // thực hiện tải hình ảnh hồ sơ trong khi người dùng vô đc màn hình chính
                    let fileName = user.profilePictureFilename
                    StorageManager.shared.uploadMediaItem(withData: data, fileName: fileName,
                                                          location: .users_pictures) { result in
                        switch result {
                        case .success(let downloadURL):
                            DatabaseManager.shared.updateUser(withId: user.id, data: ["profile_picture_url": downloadURL]) { success in
                                guard success else {
                                    print("failed to update user \(user.id) with profile picture url.")
                                    return
                                }
                                Defaults.currentUser[.profilePictureUrl] = downloadURL
                            }
                        case .failure(let error):
                            print("\(error)")
                        }
                    }
                    Defaults.currentUser[.id] = user.id
                    Defaults.currentUser[.name] = user.name
                    Defaults.currentUser[.profilePictureUrl] = ""
                    DispatchQueue.main.async {
                        vc.navigationController?.dismiss(animated: true)
                    }
                }
                // Sau khi ghi người dùng thành công, bỏ qua bước tải hình ảnh hồ sơ vì người dùng kh chọn ảnh
                else {
                    // Người dùng vô đc màn hình chính
                    Defaults.currentUser[.id] = user.id
                    Defaults.currentUser[.name] = user.name
                    Defaults.currentUser[.profilePictureUrl] = ""
                    DispatchQueue.main.async {
                        vc.navigationController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
