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

    /// Upload picture to Firebase Storage and returns completion with url string to download
    typealias UploadPictureCompletion = (Result<String, StorageErrors>) -> Void

    func uploadProfilePicture(with data: Data, filename: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(filename)").putData(data) { [weak self] metadata, error in
            guard metadata != nil, error == nil else {
                completion(.failure(.failedToUpload))
                return
            }

            self?.storage.child("images/\(filename)").downloadURL { url, error in

                guard let url = url, error == nil else {
                    completion(.failure(.failedToGetDownloadURL))
                    return
                }

                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
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

    enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
