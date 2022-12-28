//
//  Database.swift
//  ZaloChatApp
//
//  Created by huy on 27/09/2022.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import MessageKit

/// Manager object to read and write data to Firebase Firestore Database
final class DatabaseManager {
    private init() {}

    private let db = Firestore.firestore()
    /// Shared instance of class
    static let shared = DatabaseManager()
}

// MARK: List of Errors

extension DatabaseManager {
    enum DatabaseError: Error {
        // Client error
        case FailtedToGetCurrentUserCache
        case UserDocumentSerializationFailure
        case ConversationDocumentSerializationFailure
        case FailedtoSerializeMessageDocuments

        // User
        case FailedToInsertUser
        case FailtedToUpdateUser
        case FailedToListenForUser

        // Conversation
        case FailedToInsertConversation
        case FailtedToUpdateConversation
        case FailedToListenForConversation
        case FailedToListenForAllConversations
        case FailedToUpdateLatestMessageAfterUploading

        // Message

        case FailedToInsertTextMessage
        case FailedToUpdateConversationAfterInsertingTextMessage

        case FailedToInsertLocationMessage
        case FailedToUpdateConversationAfterInsertingLocationMessage

        case FailedToInsertPhotoMessage
        case FailedToUpdateConversationAfterInsertingPhotoMessage
        case FailedToGetImageDataToUploadMessagePhoto
        case FailedToUploadMessagePhoto
        case FailedToUpdatePhotoMessageAfterUploadingPhoto

        case FailedToInsertVideoMessage
        case FailedToUpdateConversationAfterInsertingVideoMessage
        case FailedToGetVideoDataToUploadMessageVideo
        case FailedToUploadMessageVideo
        case FailedToUpdateVideoMessageAfterUploadingVideo

        case FailedToInsertAudioMessage
        case FailedToUpdateConversationAfterInsertingAudioMessage
        case FailedToGetAudioDataToUploadMessageAudio
        case FailedToUploadMessageAudio
        case FailedToUpdateAudioMessageAfterUploadingAudio

        case FailedToListenForMessages
        case FailedToGetMessages

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

    func updateUser(withId id: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(id).updateData(data) {
            error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func updateConservation(withId id: String, newName: String, url: String, completion: @escaping (Bool) -> Void) {
        db.collection("conversations").whereField("members.\(id).name", isNotEqualTo: "")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.db.collection("conversations").document(document.documentID).updateData(["members.\(id).name": newName, "members.\(id).profile_picture_url": url]) {
                            error in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        }
                    
                    }
                }
        }
    }
    
    func listenForUser(with userId: String, completion: @escaping (Result<User, DatabaseError>) -> Void) -> ListenerRegistration {
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
        return listener
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
        let nameComponents = name.components(separatedBy: .whitespaces)
        nameComponents.forEach { component in
            // nếu component.count = 0, thì reduce trả về initialResult
            _ = component.reduce("") { currentString, char in
                let nextString = currentString + String(char.lowercased())
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
        guard let currentUserId = Defaults.currentUser[.id],
              let currentUserName = Defaults.currentUser[.name],
              let currentUserPictureUrl = Defaults.currentUser[.profilePictureUrl]
        else {
            completion(.failure(.FailtedToGetCurrentUserCache))
            return
        }
        let currentDate = Date()

        // "latest_message" field
        let senderData = [
            currentUserId: [
                "name": currentUserName,
                "profile_picture_url": currentUserPictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let latestMessageData = [
            "message_id":
                [
                    "content": "",
                    "content_type": "",
                    "sent_date": currentDate,
                    "sender": senderData,
                    "self": true
                ]
        ]
        // "members" field
        let membersData = [
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

        // conversation document
        let conversationData: [String: Any] = [
            "name": "",
            "picture_url": "",
            "type": 0,
            "create_at": currentDate,
            "modified_at": currentDate,
            "latest_message": latestMessageData,
            "members": membersData
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

    func listenForConversation(with conversationId: String, completion: @escaping (Result<Conversation, DatabaseError>) -> Void) -> ListenerRegistration {
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
        return listener
    }

    /// Gets and listens to all conversations for a user with given uid
    func listenForAllConversations(ofUserWithId userId: String, completion: @escaping (Result<[Conversation], DatabaseError>) -> Void) -> ListenerRegistration {
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
        return listener
    }
}

// MARK: - Message Management

extension DatabaseManager {
    /// Gets messages of a specific conversation
    func getMessages(ofConversation conversationId: String,
                     limitedToLast limit: Int,
                     completion: @escaping (Result<[Message], DatabaseError>) -> Void)
    {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messagesRef = conversationRef.collection("messages")
        let query = messagesRef.order(by: "sent_date", descending: false).limit(toLast: limit)
        query.getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents,
                  !documents.isEmpty,
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToGetMessages))
                return
            }
            let messages = documents.compactMap { document in
                var messageData = document.data()
                messageData["id"] = document.documentID
                return Message(dictionary: messageData)
            }
            guard messages.count > 0 else {
                completion(.failure(.FailedtoSerializeMessageDocuments))
                return
            }

            completion(.success(messages))
        }
    }

    /// Gets and listens for messages of a specific conversation
    func listenForMessages(ofConversation conversationId: String,
                           limitedToLast limit: Int,
                           completion: @escaping (Result<[Message], DatabaseError>) -> Void) -> ListenerRegistration
    {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messagesRef = conversationRef.collection("messages")
        let query = messagesRef.order(by: "sent_date", descending: false).limit(toLast: limit)
        let listener = query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents,
                  !documents.isEmpty,
                  error == nil
            else {
                print(error?.localizedDescription ?? "")
                completion(.failure(.FailedToListenForMessages))
                return
            }
            let messages = documents.compactMap { document in
                var messageData = document.data()
                messageData["id"] = document.documentID
                return Message(dictionary: messageData)
            }
            guard messages.count > 0 else {
                completion(.failure(.FailedtoSerializeMessageDocuments))
                return
            }

            completion(.success(messages))
        }
        return listener
    }

    // MARK: - Helper Methods

    private func insertMessage(_ messageRef: DocumentReference, withData messageData: [String: Any], completion: @escaping (Bool) -> Void) {
        messageRef.setData(messageData) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    private func updateMessage(_ messageRef: DocumentReference, withData data: [String: Any], completion: @escaping (Bool) -> Void) {
        messageRef.updateData(data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    private func updateConversation(_ conversationRef: DocumentReference, withData data: [String: Any], completion: @escaping (Bool) -> Void) {
        conversationRef.updateData(data) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    private func uploadMessageVideo(withData data: Data, fileName: String, completion: @escaping (String?) -> Void) {
        StorageManager.shared.uploadMediaItem(withData: data, fileName: fileName,
                                              location: .messages_videos) { result in
            switch result {
            case .success(let urlString):
                completion(urlString)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }

    private func uploadMessagePhoto(withData data: Data, fileName: String, completion: @escaping (String?) -> Void) {
        StorageManager.shared.uploadMediaItem(withData: data, fileName: fileName,
                                              location: .messages_pictures) { result in
            switch result {
            case .success(let urlString):
                completion(urlString)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }

    private func uploadMessageAudio(withData data: Data, fileName: String, completion: @escaping (String?) -> Void) {
        StorageManager.shared.uploadMediaItem(withData: data, fileName: fileName,
                                              location: .messages_audios) { result in
            switch result {
            case .success(let urlString):
                completion(urlString)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
}

// MARK: - Sending Message Methods

extension DatabaseManager {
    /// send a audio message to a specific conversation
    func sendAudioMessage(to conversationId: String, sender: User, audioItem: AudioItem, completion: @escaping (DatabaseError?) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        let messageId = messageRef.documentID
        let content = ",\(audioItem.duration)"
        let contentType = "audio"
        let currentDate = Date()
        let senderData = [
            sender.id: [
                "name": sender.name,
                "profile_picture_url": sender.profilePictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_date": currentDate,
            "sender": senderData
        ]

        insertMessage(messageRef, withData: messageData) { [weak self] success in
            guard success else {
                completion(.FailedToInsertAudioMessage)
                return
            }
            completion(nil)

            let dataForUpdatingConversation = [
                "latest_message": [
                    messageId:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_date": currentDate,
                            "sender": senderData,
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]
            self?.updateConversation(conversationRef, withData: dataForUpdatingConversation) { success in
                guard success else {
                    completion(.FailedToUpdateConversationAfterInsertingAudioMessage)
                    return
                }

                guard let audioData = try? Data(contentsOf: audioItem.url)
                else {
                    completion(.FailedToGetAudioDataToUploadMessageAudio)
                    return
                }
                let fileName = "\(conversationId)_\(messageId)_message_audio.mp4"

                self?.uploadMessageAudio(withData: audioData,
                                         fileName: fileName) { downloadUrlString in
                    guard let downloadUrlString = downloadUrlString else {
                        completion(.FailedToUploadMessageAudio)
                        return
                    }
                    let newContentMessageData = ["content": "\(downloadUrlString),\(audioItem.duration)"]
                    self?.updateMessage(messageRef, withData: newContentMessageData) { success in
                        guard success else {
                            completion(.FailedToUpdateAudioMessageAfterUploadingAudio)
                            return
                        }
                        // Không cần update conversation, mạng chậm mắc công gây ra lỗi
                    }
                }
            }
        }
    }

    /// send a video message to a specific conversation
    func sendVideoMessage(to conversationId: String, sender: User, videoItem: MediaItem, completion: @escaping (DatabaseError?) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        let messageId = messageRef.documentID
        let content = ""
        let contentType = "video"
        let currentDate = Date()
        let senderData = [
            sender.id: [
                "name": sender.name,
                "profile_picture_url": sender.profilePictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_date": currentDate,
            "sender": senderData
        ]

        insertMessage(messageRef, withData: messageData) { [weak self] success in
            guard success else {
                completion(.FailedToInsertVideoMessage)
                return
            }
            completion(nil)

            let dataForUpdatingConversation = [
                "latest_message": [
                    messageId:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_date": currentDate,
                            "sender": senderData,
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]
            self?.updateConversation(conversationRef, withData: dataForUpdatingConversation) { success in
                guard success else {
                    completion(.FailedToUpdateConversationAfterInsertingVideoMessage)
                    return
                }

                guard let videoUrl = videoItem.url,
                      let videoData = try? Data(contentsOf: videoUrl)
                else {
                    completion(.FailedToGetVideoDataToUploadMessageVideo)
                    return
                }
                let fileName = "\(conversationId)_\(messageId)_message_video.MOV"

                self?.uploadMessageVideo(withData: videoData,
                                         fileName: fileName) { downloadUrlString in
                    guard let downloadUrlString = downloadUrlString else {
                        completion(.FailedToUploadMessageVideo)
                        return
                    }
                    let newContentMessageData = ["content": downloadUrlString]
                    self?.updateMessage(messageRef, withData: newContentMessageData) { success in
                        guard success else {
                            completion(.FailedToUpdateVideoMessageAfterUploadingVideo)
                            return
                        }
                        // Không cần update conversation, mạng chậm mắc công gây ra lỗi
                    }
                }
            }
        }
    }

    /// send a photo message to a specific conversation
    func sendPhotoMessage(to conversationId: String, sender: User, photoItem: MediaItem, completion: @escaping (DatabaseError?) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        let messageId = messageRef.documentID
        let content = ""
        let contentType = "photo"
        let currentDate = Date()
        let senderData = [
            sender.id: [
                "name": sender.name,
                "profile_picture_url": sender.profilePictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_date": currentDate,
            "sender": senderData
        ]

        insertMessage(messageRef, withData: messageData) { [weak self] success in
            guard success else {
                completion(.FailedToInsertPhotoMessage)
                return
            }
            completion(nil)

            let dataForUpdatingConversation = [
                "latest_message": [
                    messageId:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_date": currentDate,
                            "sender": senderData,
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]
            self?.updateConversation(conversationRef, withData: dataForUpdatingConversation) { success in
                guard success else {
                    completion(.FailedToUpdateConversationAfterInsertingPhotoMessage)
                    return
                }

                guard let imageData = photoItem.image?.pngData() else {
                    completion(.FailedToGetImageDataToUploadMessagePhoto)
                    return
                }
                let fileName = "\(conversationId)_\(messageId)_message_picture.png"

                self?.uploadMessagePhoto(withData: imageData, fileName: fileName) { downloadUrlString in
                    guard let downloadUrlString = downloadUrlString else {
                        completion(.FailedToUploadMessagePhoto)
                        return
                    }
                    let newContentMessageData = ["content": downloadUrlString]
                    self?.updateMessage(messageRef, withData: newContentMessageData) { success in
                        guard success else {
                            completion(.FailedToUpdatePhotoMessageAfterUploadingPhoto)
                            return
                        }
                        // Không cần update conversation, mạng chậm mắc công gây ra lỗi
                    }
                }
            }
        }
    }

    /// send a location message to a specifice conversation
    func sendLocationMessage(to conversationId: String, sender: User, locationItem: LocationItem, completion: @escaping (DatabaseError?) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        let messageId = messageRef.documentID
        let location = locationItem.location
        let content = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
        let contentType = "location"
        let currentDate = Date()
        let senderData: [String: Any] = [
            sender.id: [
                "name": sender.name,
                "profile_picture_url": sender.profilePictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_date": currentDate,
            "sender": senderData
        ]

        insertMessage(messageRef, withData: messageData) { [weak self] success in
            guard success else {
                completion(.FailedToInsertLocationMessage)
                return
            }
            completion(nil)

            let dataForUpdatingConversation = [
                "latest_message": [
                    messageId:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_date": currentDate,
                            "sender": senderData,
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]
            self?.updateConversation(conversationRef, withData: dataForUpdatingConversation) { success in
                guard success else {
                    completion(.FailedToUpdateConversationAfterInsertingLocationMessage)
                    return
                }
            }
        }
    }

    /// send a text message to a specific conversation
    func sendTextMessage(to conversationId: String, sender: User, text: String, completion: @escaping (DatabaseError?) -> Void) {
        let conversationRef = db.collection("conversations").document(conversationId)
        let messageRef = conversationRef.collection("messages").document()
        let messageId = messageRef.documentID
        let content = text
        let contentType = "text"
        let currentDate = Date()
        let senderData: [String: Any] = [
            sender.id: [
                "name": sender.name,
                "profile_picture_url": sender.profilePictureUrl,
                "is_active": true,
                "self": true
            ]
        ]
        let messageData: [String: Any] = [
            "content": content,
            "content_type": contentType,
            "sent_date": currentDate,
            "sender": senderData
        ]

        insertMessage(messageRef, withData: messageData) { [weak self] success in
            guard success else {
                completion(.FailedToInsertTextMessage)
                return
            }
            completion(nil)

            let dataForUpdatingConversation = [
                "latest_message": [
                    messageId:
                        [
                            "content": content,
                            "content_type": contentType,
                            "sent_date": currentDate,
                            "sender": senderData,
                            "self": true
                        ]
                ],
                "modified_at": currentDate
            ]
            self?.updateConversation(conversationRef, withData: dataForUpdatingConversation) { success in
                guard success else {
                    completion(.FailedToUpdateConversationAfterInsertingTextMessage)
                    return
                }
            }
        }
    }
}
