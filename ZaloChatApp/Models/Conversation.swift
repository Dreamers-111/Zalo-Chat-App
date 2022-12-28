//
//  Conversation.swift
//  ZaloChatApp
//
//  Created by huy on 09/11/2022.
//
import FirebaseFirestore
import Foundation

struct Conversation: Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    var id: String
    var name: String
    var pictureUrl: String
    var type: Int
    var createAt: Date
    var modifiedAt: Date
    var latestMessage: Message
    var members: [User]

    var displayName: String {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return ""
        }
        if type == 0 {
            return (members.filter { $0.id != currentUserId }.first?.name)!
        }
        else {
            return name
        }
    }

    var displayPictureUrl: String {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return ""
        }
        if type == 0 {
            return (members.filter { $0.id != currentUserId }.first?.profilePictureUrl)!
        }
        else {
            return pictureUrl
        }
    }

    var displayMessage: String {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return ""
        }

        // Xử lý thành phần đầu tiên là tên của người nhắn
        var nameStr = ""
        if latestMessage.user.id == currentUserId {
            nameStr = "Bạn"
        }
        else {
            nameStr = latestMessage.user.name.components(separatedBy: .whitespaces).last ?? ""
        }

        // Xử lý thành phần thứ hai là nội dung tin nhắn
        var messageContentStr = ""
        switch latestMessage.kind {
        case .text(let text):
            messageContentStr = ": \(text)"
        case .attributedText:
            messageContentStr = " attributedText"
        case .photo:
            messageContentStr = " đã gửi một hình ảnh"
        case .video:
            messageContentStr = " đã gửi một video"
        case .location:
            messageContentStr = " đã chia sẻ một vị trí"
        case .emoji:
            messageContentStr = ": 😍😍😍😍"
        case .audio:
            messageContentStr = " đã gửi một đoạn ghi âm"
        case .contact:
            messageContentStr = " đã chia sẻ một liên hệ"
        case .linkPreview:
            messageContentStr = " đã chia sẻ một liên kết"
        case .custom:
            messageContentStr = " đã chia sẻ một tập tin"
        }

        // Gộp lại ra kết quả
        return nameStr + messageContentStr
    }

    init(id: String, name: String, pictureUrl: String, type: Int, createAt: Date, modifiedAt: Date, latestMessage: Message, members: [User]) {
        self.id = id
        self.name = name
        self.pictureUrl = pictureUrl
        self.type = type
        self.createAt = createAt
        self.modifiedAt = modifiedAt
        self.latestMessage = latestMessage
        self.members = members
    }
}

protocol ConversationDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension Conversation: ConversationDocumentSerializable {
    init?(dictionary dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let pictureUrl = dict["picture_url"] as? String,
              let type = dict["type"] as? Int,
              let createAt = dict["create_at"] as? Timestamp,
              let modifiedAt = dict["modified_at"] as? Timestamp,
              let latestMessageDict = dict["latest_message"] as? [String: Any],
              let membersDict = dict["members"] as? [String: Any]
        else { return nil }

        guard let latestMessage = Conversation.latestMessageDocumentSerialize(latestMessageDict)
        else {
            print("latest message")
            return nil
        }

        let members = Conversation.membersDocumentSerialize(membersDict)
        guard !members.isEmpty else { return nil }

        self.init(id: id,
                  name: name,
                  pictureUrl: pictureUrl,
                  type: type,
                  createAt: createAt.dateValue(),
                  modifiedAt: modifiedAt.dateValue(),
                  latestMessage: latestMessage,
                  members: members)
    }

    private static func latestMessageDocumentSerialize(_ dict: [String: Any]) -> Message? {
        guard let latestMessageId = dict.keys.first,
              var latestMessageData = dict[latestMessageId] as? [String: Any]
        else {
            return nil
        }
        latestMessageData["id"] = latestMessageId
        return Message(dictionary: latestMessageData)
    }

    private static func membersDocumentSerialize(_ dict: [String: Any]) -> [User] {
        let dataOfMembers = dict.compactMap { key, value in
            if var memberData = value as? [String: Any] {
                memberData["id"] = key
                return memberData
            }
            return nil
        }

        let members = dataOfMembers.compactMap { memberData in
            if let id = memberData["id"] as? String,
               let name = memberData["name"] as? String,
               let profilePictureUrl = memberData["profile_picture_url"] as? String,
               let isActive = memberData["is_active"] as? Int
            {
                return User(id: id,
                            name: name,
                            profilePictureUrl: profilePictureUrl,
                            isActive: isActive == 1 ? true : false)
            }
            return nil
        }
        return members
    }
}
