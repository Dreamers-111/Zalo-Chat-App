//
//  Defaults.swift
//  ZaloChatApp
//
//  Created by huy on 30/11/2022.
//

import Foundation

class Defaults {
    private init() {}
    static let currentUser = CurrentUser()

    class CurrentUser {
        fileprivate init() {}

        class Key<ValueType>: CurrentUser {
            let str: String

            init(_ str: String) {
                self.str = str
            }
        }

        static let id = Key<String?>("id")
        static let name = Key<String?>("name")
        static let profilePictureUrl = Key<String?>("profile_picture_url")

        subscript(key: Key<String?>) -> String? {
            get { return UserDefaults.standard.string(forKey: key.str) }
            set { UserDefaults.standard.set(newValue, forKey: key.str) }
        }

        func removeValue(forKey key: Key<String?>) {
            UserDefaults.standard.removeObject(forKey: key.str)
        }
    }
}
