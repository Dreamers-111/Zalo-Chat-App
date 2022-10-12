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
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("Thất bại đăng nhập người dùng với email: \(email)", error!.localizedDescription)
                DispatchQueue.main.async {
                    spinner.dismiss(animated: true)
                }
                return
            }
            print("Đăng nhập thành công người dùng với email và mật khẩu.")
            vc.navigationController?.dismiss(animated: true)
        })
    }

    func googleGetUser(completion: @escaping (GIDGoogleUser) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            guard let user = user, error == nil else {
                print(error!.localizedDescription)
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
        // Lấy LoginViewController hiện tại hiển thị, hiển thị spinner đang tải
        guard let vc = getCurrentLoginVC() else {
            print("Lấy LoginViewController hiện đang hiển thị không thành công.")
            return
        }
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: vc.view)

        // Kiểm tra xem user đã đăng nhập Google thành công hay chưa.
        guard let user = user,
              let idToken = user.authentication.idToken,
              let email = user.profile?.email,
              let displayName = user.profile?.name,
              error == nil
        else {
            print(error!.localizedDescription)
            DispatchQueue.main.async {
                spinner.dismiss(animated: true)
            }
            return
        }
        print("Đã đăng nhập thành công user vói Google", email, displayName)

        // Kiểm tra xem Google user đã đăng nhập Firebase đã đăng nhập thành công hay chưa
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) {
            authResult, error in
            guard authResult != nil, error == nil else {
                print("Đã thất bại đăng nhập Google user với Firebase.", error!.localizedDescription)
                DispatchQueue.main.async {
                    spinner.dismiss(animated: true)
                }
                return
            }
            print("Đã đăng nhập thành công Google user với Firebase.")
            vc.navigationController?.dismiss(animated: true)
        }
    }
}
