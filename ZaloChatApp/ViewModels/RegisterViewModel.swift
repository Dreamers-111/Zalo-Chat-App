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
    public static let shared = RegisterViewModel()

    private func getCurrentRegisterVC() -> RegisterViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }

        // MainTabBarController
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return nil }

        // UINavigationController của Login_RegisterViewController
        guard let nav = rootViewController.presentedViewController as? UINavigationController else { return nil }

        // RegisterViewController
        return nav.topViewController as? RegisterViewController
    }

    public func registerUser(with user: User, password: String, image: UIImage) {
        // Lấy RegisterViewController hiện tại hiển thị, hiển thị spinner đang tải
        guard let vc = getCurrentRegisterVC() else {
            print("Lấy RegisterViewController hiện đang hiển thị không thành công.")
            return
        }
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: vc.view)

        FirebaseAuth.Auth.auth().createUser(withEmail: user.userEmail, password: password) { authResult, error in
            guard let result = authResult, error == nil else {
                print("Đã thất bại đăng nhập user với email \(user.userEmail).", error!.localizedDescription)
                DispatchQueue.main.async {
                    spinner.dismiss(animated: true)
                }
                return
            }
           
            print("Đã thành công đăng nhập user với email \(user.userEmail).")
            var user = user
            user.userID = result.user.uid
            DatabaseManager.shared.insertUser(with: user) {  success in
                if success {
                    // upload image
                    let data = image.pngData()
                    
                    let fileName = user.profilePictureFilename
                    StorageManager.shared.uploadProfilePicture(with: data!, filename: fileName) { result in
                        switch result {
                        case .success(let downloadURL):
                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                            print("Download Url returned: \(downloadURL   )")
                        case .failure(let error):
                            print("StorageErrors: \(error) ")
                        }
                    }
                }
            }
            vc.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}
