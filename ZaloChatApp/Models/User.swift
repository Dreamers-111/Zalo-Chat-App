//
//  User.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import Foundation

struct User {
    
    var userID : String
    let userName: String
    let userEmail: String
    let userBitrhDay: String
    let userGender: String
    let userStatus: Bool
    
    var profilePictureFilename: String {
        return "\(userEmail)_profile_picture.png"
    }
    
}
