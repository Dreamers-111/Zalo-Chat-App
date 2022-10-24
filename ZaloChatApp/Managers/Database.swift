//
//  Database.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import FirebaseFirestore
import Foundation

/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    private init() {}

    private let db = Firestore.firestore()

    /// Shared instance of class
    public static let shared = DatabaseManager()
}

// MARK: - Account Management

extension DatabaseManager {
    /// tạo tài khoản mới

    func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        db.collection("user").document(user.userID).setData([
            "email": user.userEmail,
            "name": user.userName,
            "gender": user.userGender,
            "birthDay": user.userBitrhDay,
            "status": user.userStatus,
        ]) { error in
            guard error == nil else {
                print("Failed to write to Firebase")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
}
