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

struct User: SenderType, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    var id: String
    @NSC_UCD_RWR_Formatted var name: String
    var email: String
    var gender: String
    var birthday: String
    var profilePictureUrl: String
    var isActive: Bool

    var senderId: String {
        return id
    }

    var displayName: String {
        return name
    }

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
        self.name = name
    }

    init(id: String, name: String, profilePictureUrl: String, isActive: Bool) {
        self.id = id
        email = ""
        gender = ""
        birthday = ""
        self.profilePictureUrl = profilePictureUrl
        self.isActive = isActive
        self.name = name
    }
}

protocol UserDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension User: UserDocumentSerializable {
    init?(dictionary dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let email = dict["email"] as? String,
              let gender = dict["gender"] as? String,
              let birthday = dict["birthday"] as? String,
              let profilePictureUrl = dict["profile_picture_url"] as? String,
              let isActive = dict["is_active"] as? Int
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
