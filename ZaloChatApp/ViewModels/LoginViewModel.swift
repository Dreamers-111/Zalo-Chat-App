//
//  LoginViewModel.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import JGProgressHUD

final class LoginViewModel {
    static let shared = LoginViewModel()
    private init() {}

    private func getCurrentLoginVC() -> LoginViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }

        // MainTabBarController
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return nil }

        // UINavigationController của Login_RegisterViewController
        guard let nav = rootViewController.presentedViewController as? UINavigationController else { return nil }

        // LoginViewController
        return nav.topViewController as? LoginViewController
    }

    func firebaseSignIn(with email: String, password: String) {
        guard let vc = getCurrentLoginVC() else {
            print("Lấy LoginViewController hiện đang hiển thị không thành công.")
            return
        }
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: vc.view)

        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let authResult = authResult, error == nil else {
                print("Thất bại đăng nhập người dùng với email: \(email)", error?.localizedDescription ?? "")
                let alert = UIAlertController(title: "Bạn đã nhập sai tài khoản hoặc mật khẩu",
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
            // Đăng nhập thành công người dùng với email và mật khẩu.
            let id = authResult.user.uid
            // Lấy thông tin người dùng về để lưu vào bộ nhớ đệm
            DatabaseManager.shared.userDoesExist(withId: id) { _, userData in
                guard let userData = userData,
                      let name = userData["name"] as? String,
                      let profilePictureUrl = userData["profile_picture_url"] as? String
                else {
                    return
                }

                Defaults.currentUser[.id] = id
                Defaults.currentUser[.name] = name
                Defaults.currentUser[.profilePictureUrl] = profilePictureUrl
                DispatchQueue.main.async {
                    vc.navigationController?.dismiss(animated: true)
                }
            }
        }
    }

    func googleGetUser(completion: @escaping (GIDGoogleUser) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard let user = user, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            completion(user)
        }
    }

    func googleSignIn() {
        guard let vc = getCurrentLoginVC() else {
            print("Lấy LoginViewController hiện đang hiển thị không thành công.")
            return
        }
        // 1
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                self?.googleAuthenticateUser(for: user, with: error)
            }
        }
        else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let configuration = GIDConfiguration(clientID: clientID)

            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: vc) {
                [weak self] user, error in
                self?.googleAuthenticateUser(for: user, with: error)
            }
        }
    }

    private func googleAuthenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // Sau khi AuthenicationViewController của GoogleSignIn kết thúc
        // Lấy LoginViewController hiện tại hiển thị
        guard let vc = getCurrentLoginVC() else {
            print("Lấy LoginViewController hiện đang hiển thị không thành công.")
            return
        }

        // hiển thị spinner đang tải
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: vc.view)

        // Kiểm tra xem user đã đăng nhập vô Google thành công hay chưa.
        guard let user = user,
              let idToken = user.authentication.idToken,
              let email = user.profile?.email,
              let name = user.profile?.name,
              let userHasImage = user.profile?.hasImage,
              error == nil
        else {
            print(error?.localizedDescription ?? "")
            DispatchQueue.main.async {
                spinner.dismiss(animated: true)
            }
            return
        }

        // Người dùng đã đăng nhập vô Google thành công
        // Người dùng đăng nhập vào app từ credential của Google Auth Provider. Nếu email đã được sử dụng để đăng nhập qua phương thức email&password, thì người dùng sẽ không đăng nhập được
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)

        FirebaseAuth.Auth.auth().signIn(with: credential) {
            authResult, error in
            guard let authResult = authResult, error == nil else {
                print("Người dùng thất bại đăng nhập vào app qua Google.", error?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    spinner.dismiss(animated: true)
                }
                return
            }
            print("Người dùng đăng nhập thành công vô apps")
            /// Người dùng đăng nhập thành công vô app
            /// Sau khi người dùng đăng nhập thành công vô app, thực hiện ghi người dùng database nếu người dùng lần đầu tiên đăng nhập vô app qua google, lúc này chưa có thông tin người dùng
            let id = authResult.user.uid

            // Kiểm tra đã có thông tin người dùng trên database chưa
            DatabaseManager.shared.userDoesExist(withId: id) { _, userData in
                /// Kiểm tra xong, thấy đã có thông tin người dùng,
                /// lấy url hình ảnh hồ sơ cùng với các thông tin có sẵn khác từ hàm  như name, id để lấy vào bộ nhớ đệm.
                if let userData = userData,
                   let profilePictureUrl = userData["profile_picture_url"] as? String
                {
                    // Người dùng vô đc màn hình chính
                    Defaults.currentUser[.id] = id
                    Defaults.currentUser[.name] = name
                    Defaults.currentUser[.profilePictureUrl] = profilePictureUrl
                    DispatchQueue.main.async {
                        vc.navigationController?.dismiss(animated: true)
                    }
                }
                // Kiểm tra xong, không thấy thông tin người dùng, th thực hiện ghi người dùng vào database
                else {
                    // insert to database
                    let newUser = User(id: id,
                                       name: name,
                                       email: email,
                                       gender: "",
                                       birthday: "",
                                       profilePictureUrl: "",
                                       isActive: true)
                    DatabaseManager.shared.insertUser(with: newUser) { success in
                        guard success else {
                            print("failed to insert user \(id) into database")
                            DispatchQueue.main.async {
                                spinner.dismiss(animated: true)
                            }
                            return
                        }
                        // Ghi người dùng vào database thành công
                        // Sau khi ghi người dùng thành công, thực hiện tải hình ảnh hồ sơ nếu người dùng có ảnh
                        if userHasImage, let pictureURL = user.profile?.imageURL(withDimension: 200) {
                            // Downloading data from Google image url
                            URLSession.shared.dataTask(with: pictureURL) { data, _, error in
                                guard let data = data, error == nil else {
                                    print("Failed to get data from Google.")
                                    DispatchQueue.main.async {
                                        spinner.dismiss(animated: true)
                                    }
                                    return
                                }
                                // Got data from Google. Uploading...
                                // thực hiện tải hình ảnh hồ sơ trong khi người dùng vô đc màn hình chính
                                let fileName = newUser.profilePictureFilename
                                StorageManager.shared.uploadMediaItem(withData: data,
                                                                      fileName: fileName,
                                                                      location: .users_pictures)
                                { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        DatabaseManager.shared.updateUser(withId: id, data: ["profile_picture_url": downloadURL]) { success in
                                            guard success else {
                                                print("failed to update user \(id) with profile picture url.")
                                                return
                                            }
                                            Defaults.currentUser[.profilePictureUrl] = downloadURL
                                        }
                                    case .failure(let error):
                                        print("\(error)")
                                    }
                                }
                                Defaults.currentUser[.id] = id
                                Defaults.currentUser[.name] = name
                                Defaults.currentUser[.profilePictureUrl] = ""
                                DispatchQueue.main.async {
                                    vc.navigationController?.dismiss(animated: true)
                                }
                            }.resume()
                        }
                        // Sau khi ghi người dùng thành công, bỏ qua bước tải hình ảnh hồ sơ vì người dùng kh có ảnh
                        else {
                            // Người dùng vô đc màn hình chính
                            Defaults.currentUser[.id] = id
                            Defaults.currentUser[.name] = name
                            Defaults.currentUser[.profilePictureUrl] = ""
                            DispatchQueue.main.async {
                                vc.navigationController?.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
