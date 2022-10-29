//
//  User.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import Foundation

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

struct User {
    var id: String
    @NSC_UCD_RWR_Formatted var name: String
    var email: String
    var birthday: String
    var gender: String
    var status: Bool

    var profilePictureFilename: String {
        return "\(email)_profile_picture.png"
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "gender": gender,
            "birthday": birthday,
            "status": status
        ]
    }

    init(id: String, name: String, email: String, birthday: String, gender: String, status: Bool) {
        self.id = id
        self.email = email
        self.birthday = birthday
        self.gender = gender
        self.status = status
        self.name = name
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
              let status = dictionary["status"] as? Int
        else { return nil }

        self.init(id: id, name: name, email: email, birthday: birthday, gender: gender, status: status == 1 ? true : false)
    }
}
