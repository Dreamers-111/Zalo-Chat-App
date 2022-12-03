//
//  Message.swift
//  ZaloChatApp
//
//  Created by huy on 14/11/2022.
//

import FirebaseFirestore
import Foundation
import MessageKit
import CoreLocation

struct Message: MessageType {
    var messageId: String

    var kind: MessageKit.MessageKind

    var sentDate: Date

    var sender: MessageKit.SenderType

    var readBy: [String]

    var content: Any {
        switch kind {
        case .text(let text):
            return text
        case .attributedText:
            return ""
        case .photo:
            return ""
        case .video:
            return ""
        case .location:
            return ""
        case .emoji:
            return ""
        case .audio:
            return ""
        case .contact:
            return ""
        case .linkPreview:
            return ""
        case .custom:
            return ""
        }
    }

    var contentType: String {
        switch kind {
        case .text:
            return "text"
        case .attributedText:
            return "attributedText"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .location:
            return "location"
        case .emoji:
            return "emoji"
        case .audio:
            return "audio"
        case .contact:
            return "contact"
        case .linkPreview:
            return "linkPreview"
        case .custom:
            return "custom"
        }
    }

    init(messageId: String, kind: MessageKit.MessageKind, sentDate: Date, sender: MessageKit.SenderType, readBy: [String]) {
        self.messageId = messageId
        self.kind = kind
        self.sentDate = sentDate
        self.sender = sender
        self.readBy = readBy
    }

    init() {
        messageId = ""
        kind = .text("")
        sentDate = Date()
        sender = User()
        readBy = []
    }

    init(messageId: String, content: Any, contentType: String, sentDate: Date, sender: MessageKit.SenderType, readBy: [String]) {
        self.messageId = messageId
        switch contentType {
        case "text":
            kind = .text(content as? String ?? "")
        case "attributedText":
            kind = .text("")
        case "photo":
            kind = .text("")
        case "video":
            kind = .text("")

        case "location":
            kind = .text("")

        case "emoji":
            kind = .text("")

        case "audio":
            kind = .text("")

        case "contact":
            kind = .text("")

        case "linkPreview":
            kind = .text("")

        case "custom":
            kind = .text("")

        default:
            kind = .text("")
        }
        self.sentDate = sentDate
        self.sender = sender
        self.readBy = readBy
    }
}

protocol MessageDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension Message: MessageDocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let contentType = dictionary["content_type"] as? String,
              let sentAt = dictionary["sent_at"] as? Timestamp,
              let senderDict = dictionary["sent_by"] as? [String: Any],
              let senderId = senderDict.keys.first,
              let senderData = senderDict[senderId] as? [String: Any],
              let senderName = senderData["name"] as? String,
              let senderProfilePictureUrl = senderData["profile_picture_url"] as? String,
              let senderIsActive = senderData["is_active"] as? Int,
              let readBy = dictionary["read_by"] as? [String: Any]
        else { return nil }
        
        var kind: MessageKind?
        if contentType == "photo" {
            // photo
            guard let imageUrl = URL(string: content),
                  let placeHolder = UIImage(systemName: "plus")
            else {
                return nil
            }
            let media = Media(url: imageUrl,
                              image: nil,
                              placeholderImage: placeHolder,
                              size: CGSize(width: 300, height: 300))
            kind = .photo(media)
        }

        else if contentType == "video" {
            // video
            guard let videoUrl = URL(string: content),
                  let placeHolder = UIImage(named: "video_placeholder")
            else {
                return nil
            }

            let media = Media(url: videoUrl,
                              image: nil,
                              placeholderImage: placeHolder,
                              size: CGSize(width: 300, height: 300))
            kind = .video(media)
        }

        else if contentType == "location" {
            let locationComponents = content.components(separatedBy: ",")
            guard let longitude = Double(locationComponents[0]),
                let latitude = Double(locationComponents[1]) else {
                return nil
            }
            print("Rendering location; long=\(longitude) | lat=\(latitude)")
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                    size: CGSize(width: 300, height: 300))
            kind = .location(location)
        }
        else {
            kind = .text(content)
        }

        guard let finalKind = kind else {
            return nil
        }

        let sender = User(id: senderId,
                          name: senderName,
                          profilePictureUrl: senderProfilePictureUrl,
                          isActive: senderIsActive == 1 ? true : false)

//        self.init(messageId: id, content: content, contentType: contentType, sentDate: sentAt.dateValue(), sender: sender, readBy: Array(readBy.keys))
        
        self.init(messageId: id, kind: finalKind, sentDate: sentAt.dateValue(), sender: sender, readBy: Array(readBy.keys))
    }
}

// MARK: - SEND MEDIA MESSAGE
struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}
