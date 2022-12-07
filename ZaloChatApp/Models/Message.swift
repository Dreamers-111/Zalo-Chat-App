//
//  Message.swift
//  ZaloChatApp
//
//  Created by huy on 14/11/2022.
//

import AVFoundation
import CoreLocation
import FirebaseFirestore
import Foundation
import MessageKit
import UIKit

// MARK: - MessageCoordinateItem

struct MessageCoordinateItem: LocationItem {
    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        size = CGSize(width: 240, height: 240)
    }
}

// MARK: - MessageImageMediaItem

struct MessageImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }

    init(imageURL: URL?) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

// MARK: - MessageAudioItem

struct MessageAudioItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }
}

// MARK: - MessageContactItem

struct MessageContactItem: ContactItem {
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]

    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
}

// MARK: - MessageLinkItem

struct MessageLinkItem: LinkItem {
    let text: String?
    let attributedText: NSAttributedString?
    let url: URL
    let title: String?
    let teaser: String
    let thumbnailImage: UIImage
}

struct Message: MessageType {
    // MARK: - Property

    var id: String

    var kind: MessageKit.MessageKind

    var sentDate: Date

    var user: User

    var sender: MessageKit.SenderType {
        return user
    }

    var messageId: String {
        return id
    }

    // MARK: - Private Init

    private init(id: String, kind: MessageKit.MessageKind, sentDate: Date, user: User) {
        self.id = id
        self.kind = kind
        self.sentDate = sentDate
        self.user = user
    }

    // MARK: - Init

    init(id: String, custom: Any?, sentDate: Date, user: User) {
        self.init(id: id, kind: .custom(custom), sentDate: sentDate, user: user)
    }

    init(id: String, text: String, sentDate: Date, user: User) {
        self.init(id: id, kind: .text(text), sentDate: sentDate, user: user)
    }

    init(id: String, attributedText: NSAttributedString, sentDate: Date, user: User) {
        self.init(id: id, kind: .attributedText(attributedText), sentDate: sentDate, user: user)
    }

    init(id: String, image: UIImage, sentDate: Date, user: User) {
        let mediaItem = MessageImageMediaItem(image: image)
        self.init(id: id, kind: .photo(mediaItem), sentDate: sentDate, user: user)
    }

    init(id: String, imageURL: URL?, sentDate: Date, user: User) {
        let mediaItem = MessageImageMediaItem(imageURL: imageURL)
        self.init(id: id, kind: .photo(mediaItem), sentDate: sentDate, user: user)
    }

    init(id: String, videoURL: URL, sentDate: Date, user: User) {
        let mediaItem = MessageImageMediaItem(imageURL: videoURL)
        self.init(id: id, kind: .video(mediaItem), sentDate: sentDate, user: user)
    }

    init(id: String, videoThumbnail: UIImage, sentDate: Date, user: User) {
        let mediaItem = MessageImageMediaItem(image: videoThumbnail)
        self.init(id: id, kind: .video(mediaItem), sentDate: sentDate, user: user)
    }

    init(id: String, location: CLLocation, sentDate: Date, user: User) {
        let locationItem = MessageCoordinateItem(location: location)
        self.init(id: id, kind: .location(locationItem), sentDate: sentDate, user: user)
    }

    init(id: String, emoji: String, sentDate: Date, user: User) {
        self.init(id: id, kind: .emoji(emoji), sentDate: sentDate, user: user)
    }

    init(id: String, audioURL: URL, sentDate: Date, user: User) {
        let audioItem = MessageAudioItem(url: audioURL)
        self.init(id: id, kind: .audio(audioItem), sentDate: sentDate, user: user)
    }

    init(id: String, contact: MessageContactItem, sentDate: Date, user: User) {
        self.init(id: id, kind: .contact(contact), sentDate: sentDate, user: user)
    }

    init(id: String, linkItem: MessageLinkItem, sentDate: Date, user: User) {
        self.init(id: id, kind: .linkPreview(linkItem), sentDate: sentDate, user: user)
    }
}

// MARK: - Document Serialization

protocol MessageDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension Message: MessageDocumentSerializable {
    init?(dictionary dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let content = dict["content"] as? String,
              let contentType = dict["content_type"] as? String,
              let sentDate = dict["sent_date"] as? Timestamp,
              let senderDict = dict["sender"] as? [String: Any]
        else { return nil }

        // Xử lý dữ liệu người gửi tin nhắn
        guard let senderId = senderDict.keys.first,
              let senderData = senderDict[senderId] as? [String: Any],
              let senderName = senderData["name"] as? String,
              let senderProfilePictureUrl = senderData["profile_picture_url"] as? String,
              let senderIsActive = senderData["is_active"] as? Int
        else { return nil }

        let user = User(id: senderId,
                        name: senderName,
                        profilePictureUrl: senderProfilePictureUrl,
                        isActive: senderIsActive == 1 ? true : false)

        // Xử lý dữ liệu tin nhắn (nội dung, phân loại)
        switch contentType {
        case "text":
            self.init(id: id, text: content, sentDate: sentDate.dateValue(), user: user)
        case "photo":
            self.init(id: id, imageURL: URL(string: content), sentDate: sentDate.dateValue(), user: user)
        case "video":
            fallthrough
        case "location":
            let locationComponents = content.components(separatedBy: ",")
            guard let longitude = Double(locationComponents[0]),
                  let latitude = Double(locationComponents[1])
            else {
                return nil
            }
            let location = CLLocation(latitude: latitude, longitude: longitude)
            self.init(id: id, location: location, sentDate: sentDate.dateValue(), user: user)
        default:
            return nil
        }
    }
}
