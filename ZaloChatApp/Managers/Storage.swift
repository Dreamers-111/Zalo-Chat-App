//
//  Storage.swift
//  ZaloChatApp
//
//  Created by Phạm Văn Nam on 18/10/2022.
//

import FirebaseStorage
import Foundation

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    private let storage = Storage.storage().reference()
    
    /*
     example fileName: /images/nam@gmail.com_profile_picture.png
     */
    enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }

    enum Location: String {
        case users
        case users_pictures = "users/pictures"
        case messages
        case messages_pictures = "messages/pictures"
        case messages_videos = "messages/videos"
    }
    
    typealias downloadURLCompletion = (Result<URL, StorageErrors>) -> Void
    
    func downloadURL(for path: String, completion: @escaping downloadURLCompletion) {
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    /// Upload picture to Firebase Storage and returns completion with url string to download
    typealias uploadMediaItemCompletion = (Result<String, StorageErrors>) -> Void
    
    func uploadMediaItem(withData data: Data, fileName: String, location: Location, completion: @escaping uploadMediaItemCompletion) {
        storage.child("\(location.rawValue)/\(fileName)").putData(data) { [weak self] metadata, error in
            guard metadata != nil, error == nil else {
                completion(.failure(.failedToUpload))
                return
            }
            
            self?.storage.child("\(location.rawValue)/\(fileName)").downloadURL { url, error in
                
                guard let url = url, error == nil else {
                    completion(.failure(.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    /// Upload video that will be sent in a conversation message
    func uploadMediaItem(withUrl url: URL, fileName: String, location: Location, completion: @escaping uploadMediaItemCompletion) {
        storage.child("\(location.rawValue)/\(fileName)").putFile(from: url) { [weak self] metadata, error in
            guard metadata != nil, error == nil else {
                completion(.failure(.failedToUpload))
                return
            }
            
            self?.storage.child("\(location.rawValue)/\(fileName)").downloadURL { url, error in
                
                guard let url = url, error == nil else {
                    completion(.failure(.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
}
