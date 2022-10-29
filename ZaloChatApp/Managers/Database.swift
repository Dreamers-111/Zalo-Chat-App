//
//  Database.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import FirebaseFirestore
import Foundation

/// Manager object to read and write data to Firebase Firestore Database
final class DatabaseManager {
    private init() {}

    private let db = Firestore.firestore()

    /// Shared instance of class
    public static let shared = DatabaseManager()
}

// MARK: - User Management

extension DatabaseManager {
    func userDoesExist(email: String, completion: @escaping (Bool) -> Void) {
        let safeEmailAddress = email.replacingOccurrences(of: ".", with: "-")
        let document = db.collection("users").document(safeEmailAddress)
        document.getDocument { document, error in
            guard let data = document?.data(),
                  error == nil
            else {
                completion(false)
                return
            }
            print("User does exist on FirestoreDatabase", data)
            completion(true)
        }
    }

    /// tạo tài khoản mới

    func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        db.collection("user").document(user.id).setData([
            "email": user.email,
            "name": user.name,
            "gender": user.gender,
            "birthday": user.birthday,
            "status": user.status,
            "keywords": createUserSearchKeywords(withName: user.$name)
        ]) { error in
            guard error == nil else {
                print("Failed to write to Firebase Firestore")
                completion(false)
                return
            }
            completion(true)
        }
    }
}

// MARK: - User Search Management

extension DatabaseManager {
    typealias searchUsersCompletion = (Result<[User], DatabaseSearchError>) -> Void
    func searchUsers(thatHaveNamesLike searchText: String, completion: @escaping searchUsersCompletion) {
        let searchTextComponents = searchText.NSC_UCR_RWR_map()
        guard !searchTextComponents.isEmpty else {
            completion(.failure(.InvalidSearchText))
            return
        }

        let usersRef = db.collection("users")
        var query = usersRef.whereField("keywords.\(searchTextComponents[0])", isEqualTo: true)
        for (index, component) in searchTextComponents.enumerated() {
            guard index != 0 else {
                continue
            }
            query = query.whereField("keywords.\(component)", isEqualTo: true)
        }
        query.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot, error == nil else {
                print(error!.localizedDescription)
                completion(.failure(.failedToSearchUsers))
                return
            }
            let results = querySnapshot.documents.compactMap { document in
                var userDict = document.data()
                userDict["keywords"] = nil
                return User(dictionary: userDict)
            }

            guard results.count > 0 else {
                completion(.failure(.DocumentSerializationFailure))
                return
            }
            completion(.success(results))
        }
    }

    private func createUserSearchKeywords(withName name: String) -> [String: Bool] {
        // không cần phải .trimmingCharacters(in: .whitespacesAndNewlines)
        // vì ở dưới reduce sẽ xử lý
        var keywords = [String: Bool]()
        let nameComponents = name.lowercased().components(separatedBy: .whitespaces)
        nameComponents.forEach { component in
            // nếu component.count = 0, thì reduce trả về initialResult
            _ = component.reduce("") { currentString, char in
                // char is of type String.Element (aka 'Character')
                let nextString = currentString + String(char)
                keywords[nextString] = true
                return nextString
            }
        }
        return keywords
    }

    enum DatabaseSearchError: Error {
        case InvalidSearchText
        case failedToSearchUsers
        case DocumentSerializationFailure
    }
}
