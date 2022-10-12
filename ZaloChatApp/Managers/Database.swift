//
//  Database.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import Foundation
import FirebaseFirestore

/// Manager object to read and write data to real time firebase database
final class DatabaseManager {
    
    private init(){
    }
    
    private let db = Firestore.firestore()

    /// Shared instance of class
    public static let shared = DatabaseManager()

}

// MARK: - Account Management
extension DatabaseManager {

    /// tạo tài khoản mới
    public func insertUser(with user: User){
        
        db.collection("user").document(user.userID).setData([
            "email": user.userEmail,
            "name" : user.userName,
            "gender": user.userGender,
            "birthDay" : user.userBitrhDay,
            "status": user.userStatus])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

    }

    
}
