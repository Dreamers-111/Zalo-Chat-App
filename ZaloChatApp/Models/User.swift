//
//  User.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import Foundation
import MessageKit

@propertyWrapper
struct NSC_UCD_RWR_Formatted {
    private var str: String
    private(set) var projectedValue: String
    var wrappedValue: String {
        get { return str }
        set { (str, projectedValue) = newValue.NSC_UCD_RWR_map() }
    }

    init() {
        str = ""
        projectedValue = ""
    }
}

struct User: SenderType {
    var id: String
    @NSC_UCD_RWR_Formatted var name: String
    var email: String
    var gender: String
    var birthday: String
    var profilePictureUrl: String
    var isActive: Bool

    var senderId: String
    var displayName: String

    var profilePictureFilename: String {
        return "\(email)_profile_picture.png"
    }

    init() {
        id = ""
        email = ""
        gender = ""
        birthday = ""
        profilePictureUrl = ""
        isActive = false
        senderId = ""
        displayName = ""
        name = ""
    }

    init(id: String,
         name: String,
         email: String,
         gender: String,
         birthday: String,
         profilePictureUrl: String,
         isActive: Bool)
    {
        self.id = id
        self.email = email
        self.gender = gender
        self.birthday = birthday
        self.profilePictureUrl = profilePictureUrl
        self.isActive = isActive
        senderId = ""
        displayName = ""
        self.name = name

        // tuân theo protocol SenderType
        senderId = self.id
        displayName = self.name
    }

    init(id: String, name: String, profilePictureUrl: String, isActive: Bool) {
        self.id = id
        email = ""
        gender = ""
        birthday = ""
        self.profilePictureUrl = profilePictureUrl
        self.isActive = isActive
        senderId = ""
        displayName = ""
        self.name = name

        // tuân theo protocol SenderType
        senderId = self.id
        displayName = self.name
    }
}

protocol UserDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension User: UserDocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String,
              let gender = dictionary["gender"] as? String,
              let birthday = dictionary["birthday"] as? String,
              let profilePictureUrl = dictionary["profile_picture_url"] as? String,
              let isActive = dictionary["is_active"] as? Int
        else { return nil }

        self.init(id: id,
                  name: name,
                  email: email,
                  gender: gender,
                  birthday: birthday,
                  profilePictureUrl: profilePictureUrl,
                  isActive: isActive == 1 ? true : false)
    }
}
