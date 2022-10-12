//
//  RegisterViewModel.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 12/10/2022.
//

import Foundation
import FirebaseAuth

/// Manager object to read and write data to real time firebase database
final class RegisterViewModel {
    
    private init(){
    }
    
    /// Shared instance of class
    public static let shared = RegisterViewModel()
    
    public func registerUser(with user : User, password : String)
    {
        FirebaseAuth.Auth.auth().createUser(withEmail: user.userEmail, password: password, completion: { authResult, error in
            
            guard let result = authResult, error == nil else {
                //strongSelf.alertUserLoginError(message: "Email đã tồn tại")
                return
            }
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            // UINavigationController lồng LoginViewController
            guard let registNav = rootViewController.presentedViewController else { return }
            
            var user = user
            
            user.userID = result.user.uid
            
            DatabaseManager.shared.insertUser(with: user)
            
            registNav.dismiss(animated: true, completion: nil)
            
        })
    }

}

