//
//  Database.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import FirebaseFirestore
import Foundation
import MessageKit
import CoreLocation

/// Manager object to read and write data to Firebase Firestore Database
final class DatabaseManager {
    private init() {}

    private let db = Firestore.firestore()
    /// Shared instance of class
    static let shared = DatabaseManager()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

    private var userListener: ListenerRegistration?
    private var conversationListener: ListenerRegistration?
    private var allConverationsListener: ListenerRegistration?
    private var allMessagesListener: ListenerRegistration?

    var isListeningForUser: Bool {
        return userListener != nil ? true : false
    }

    var isListeningForConversation: Bool {
        return conversationListener != nil ? true : false
    }

    var isListeningForAllConversations: Bool {
        return allConverationsListener != nil ? true : false
    }

    var isListeningForAllMessages: Bool {
        return allMessagesListener != nil ? true : false
    }

    func removeAllListeners() {
        userListener?.remove()
        conversationListener?.remove()
        allConverationsListener?.remove()
        allMessagesListener?.remove()

        userListener = nil
        conversationListener = nil
        allConverationsListener = nil
        allMessagesListener = nil
    }

    func removeListenersForChatViewController() {
        conversationListener?.remove()
        allMessagesListener?.remove()

        conversationListener = nil
        allMessagesListener = nil
    }

    // Dùng để kiểm tra
    func printAllListeners() {
        print(userListener as Any)
        print(conversationListener as Any)
        print(allConverationsListener as Any)
        print(allMessagesListener as Any)
    }

    enum DatabaseError: Error {
        // Client error
        case FailtedToGetCurrentUserCache
        case UserDocumentSerializationFailure
        case ConversationDocumentSerializationFailure
        case MessageDocumentSerializationFailure

        // User
        case FailedToInsertUser
        case FailtedToUpdateUser
        case FailedToListenForUser

        // Conversation
        case FailedToInsertConversation
        case FailtedToUpdateConversation
        case FailedToListenForConversation
        case FailedToListenForAllConversations

        // Message
        case FailedToInsertMessage

        case FailedToListenForAllMessages

        // Search
        case InvalidSearchText
        case failedToSearchForUsers
    }
}

// MARK: - User Management

extension DatabaseManager {
    typealias userDoesExistCompletion = (DocumentReference, [String: Any]?) -> Void
    func userDoesExist(withId id: String, completion: @escaping userDoesExistCompletion) {
        let userRef = db.collection("users").document(id)
        userRef.getDocument { docSnapshot, error in
            guard let document = docSnapshot,
                  let data = document.data(),
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(userRef, nil)
                return
            }
            completion(userRef, data)
        }
    }

    /// tạo tài khoản mới
    func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(user.id).setData([
            "name": user.name,
            "email": user.email,
            "gender": user.gender,
            "birthday": user.birthday,
            "profile_picture_url": user.profilePictureUrl,
            "is_active": user.isActive,
            "keywords": createUserSearchKeywords(withName: user.$name),
            "groups": [String: Any](),
            "members": [String: Any]()
        ]) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    func updateUserWithProfilePictureUrl(withId id: String, downloadUrl: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(id).updateData(["profile_picture_url": downloadUrl]) {
            error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    func listenForUser(with userId: String, completion: @escaping (Result<User, DatabaseError>) -> Void) {
        let userRef = db.collection("users").document(userId)
        let listener = userRef.addSnapshotListener { docSnapshot, error in
            guard let docSnapshot = docSnapshot,
                  var data = docSnapshot.data(),
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToListenForUser))
                return
            }

            data["id"] = userId
            guard let user = User(dictionary: data) else {
                completion(.failure(.UserDocumentSerializationFailure))
                return
            }
            completion(.success(user))
        }
        userListener = listener
    }
}

// MARK: - User Search

extension DatabaseManager {
    typealias searchUsersCompletion = (Result<[User], DatabaseError>) -> Void
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
            guard let documents = querySnapshot?.documents,
                  !documents.isEmpty,
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.failedToSearchForUsers))
                return
            }

            let users = documents.compactMap { document in
                var userData = document.data()
                userData["id"] = document.documentID
                return User(dictionary: userData)
            }
            guard users.count > 0 else {
                completion(.failure(.UserDocumentSerializationFailure))
                return
            }
            completion(.success(users))
        }
    }

    private func createUserSearchKeywords(withName name: String) -> [String: Bool] {
        var keywords = [String: Bool]()
        let nameComponents = name.lowercased().components(separatedBy: .whitespaces)
        nameComponents.forEach { component in
            // nếu component.count = 0, thì reduce trả về initialResult
            _ = component.reduce("") { currentString, char in
                let nextString = currentString + String(char)
                keywords[nextString] = true
                return nextString
            }
        }
        return keywords
    }
}

// MARK: - Conversation Management

extension DatabaseManager {
    /// Creates a new private conversation with target user
    func createNewPrivateConversation(with targetUser: User, completion: @escaping (Result<String, DatabaseError>) -> Void) {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String,
              let currentUserPictureUrl = UserDefaults.standard.value(forKey: "profile_picture_url") as? String
        else {
            completion(.failure(.FailtedToGetCurrentUserCache))
            return
        }
        let currentDate = Date()
        let conversationData: [String: Any] = [
            "name": "",
            "picture_url": "",
            "type": 0,
            "create_at": currentDate,
            "create_by": "",
            "modified_at": currentDate,
            "latest_message": [String: Any](),
            "members": [
                currentUserId:
                    [
                        "name": currentUserName,
                        "profile_picture_url": currentUserPictureUrl,
                        "is_active": true,
                        "self": true
                    ],
                targetUser.id:
                    [
                        "name": targetUser.name,
                        "profile_picture_url": targetUser.profilePictureUrl,
                        "is_active": targetUser.isActive,
                        "self": true
                    ]
            ]
        ]
        let conversationRef = db.collection("conversations").document()
        conversationRef.setData(conversationData) { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToInsertConversation))
                return
            }
            completion(.success(conversationRef.documentID))
        }
    }

    func listenForConversation(with conversationId: String, completion: @escaping (Result<Conversation, DatabaseError>) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let listener = conversationRef.addSnapshotListener { docSnapshot, error in
            guard var data = docSnapshot?.data(),
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToListenForConversation))
                return
            }

            data["id"] = conversationId
            guard let conversation = Conversation(dictionary: data) else {
                completion(.failure(.ConversationDocumentSerializationFailure))
                return
            }
            completion(.success(conversation))
        }
        conversationListener = listener
    }

    /// Gets and listens to all conversations for a user with given uid
    func listenForAllConversations(ofUserWithId userId: String, completion: @escaping (Result<[Conversation], DatabaseError>) -> Void) {
        let conversationsRef = db.collection("conversations")
        let query = conversationsRef.whereField("members.\(userId).self", isEqualTo: true)
        let listener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents,
                  !documents.isEmpty,
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToListenForAllConversations))
                return
            }
            let conversations = documents.compactMap { document in
                var conversationData = document.data()
                conversationData["id"] = document.documentID
                return Conversation(dictionary: conversationData)
            }
            guard conversations.count > 0 else {
                completion(.failure(.ConversationDocumentSerializationFailure))
                return
            }

            completion(.success(conversations.sorted { $0.modifiedAt > $1.modifiedAt }))
        }
        allConverationsListener = listener
    }
}

// MARK: - Message Management

extension DatabaseManager {
    /// Gets and listens to all messages for a given conversation
    func listenForAllMessages(ofConvoWithId conversationId: String, completion: @escaping (Result<[Message], DatabaseError>) -> Void)
    {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messagesRef = conversationRef.collection("messages")
        let query = messagesRef.order(by: "sent_at", descending: false)
        let listener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents,
                  !documents.isEmpty,
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToListenForAllMessages))
                return
            }
            let messages = documents.compactMap { document in
                var messageData = document.data()
                messageData["id"] = document.documentID
                return Message(dictionary: messageData)
            }
            guard messages.count > 0 else {
                completion(.failure(.MessageDocumentSerializationFailure))
                return
            }
            
            completion(.success(messages))
        }
        allMessagesListener = listener
    }

    /// Sends a message with target conversation and message
    func sendMessage(to conversationId: String, message: MessageKind, completion: @escaping (DatabaseError?) -> Void) {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String,
              let currentUserPictureUrl = UserDefaults.standard.value(forKey: "profile_picture_url") as? String
        else {
            completion(.FailtedToGetCurrentUserCache)
            return
        }

        var content = ""
        var contentType = ""
        switch message {
        case .text(let text):
            content = text
            contentType = "text"
        case .attributedText:
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                content = targetUrlString
                contentType = "photo"
            }
            break
        case .video(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString {
                content = targetUrlString
                contentType = "video"
            }
            break
        case .location(let locationData):
            let location = locationData.location
            content = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
            contentType = "location"
            break
        case .emoji:
            break
        case .audio:
            break
        case .contact:
            break
        case .linkPreview:
            break
        case .custom:
            break
        }

        let currentDate = Date()
        let sender: [String: Any] = [
            currentUserId: [
                "name": currentUserName,
                "profile_picture_url": currentUserPictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_at": currentDate,
            "sent_by": sender,
            "read_by": [currentUserId: true]
        ]
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        messageRef.setData(messageData) { error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                completion(.FailedToInsertMessage)
                return
            }
            conversationRef.updateData([
                "latest_message": [
                    messageRef.documentID:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_at": currentDate,
                            "sent_by": sender,
                            "read_by": [currentUserId: true],
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]) {
                error in
                guard error == nil else {
                    print(error?.localizedDescription ?? "")
                    completion(.FailtedToUpdateConversation)
                    return
                }
                completion(nil)
            }
        }
    }
}
