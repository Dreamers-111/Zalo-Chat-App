//
//  Conversation.swift
//  ZaloChatApp
//
//  Created by huy on 09/11/2022.
//
import FirebaseFirestore
import Foundation

struct Conversation {
    var id: String
    var name: String
    var pictureUrl: String
    var type: Int
    var createAt: Date
    var createBy: String
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
        var nameComponent = ""
        if latestMessage.sender.senderId == currentUserId {
            nameComponent = "Bạn"
        }
        else {
            nameComponent = latestMessage.sender.displayName.components(separatedBy: .whitespaces).last ?? ""
        }

        // Xử lý thành phần thứ hai là nội dung tin nhắn
        var messageContentComponent = ""
        switch latestMessage.kind {
        case .text(let text):
            messageContentComponent = ": \(text)"
        case .attributedText:
            messageContentComponent = " attributedText"
        case .photo:
            messageContentComponent = " đã gửi một hình ảnh"
        case .video:
            messageContentComponent = " đã gửi một video"
        case .location:
            messageContentComponent = " đã chia sẻ một vị trí"
        case .emoji:
            messageContentComponent = ": 😍😍😍😍"
        case .audio:
            messageContentComponent = " đã gửi một đoạn ghi âm"
        case .contact:
            messageContentComponent = " đã chia sẻ một liên hệ"
        case .linkPreview:
            messageContentComponent = " đã chia sẻ một liên kết"
        case .custom:
            messageContentComponent = " đã chia sẻ một tập tin"
        }

        // Gộp lại ra kết quả
        return nameComponent + messageContentComponent
    }

    init(id: String, name: String, pictureUrl: String, type: Int, createAt: Date, createBy: String, modifiedAt: Date, latestMessage: Message, members: [User]) {
        self.id = id
        self.name = name
        self.pictureUrl = pictureUrl
        self.type = type
        self.createAt = createAt
        self.createBy = createBy
        self.modifiedAt = modifiedAt
        self.latestMessage = latestMessage
        self.members = members
    }
}

protocol ConversationDocumentSerializable {
    init?(dictionary: [String: Any])
}

extension Conversation: ConversationDocumentSerializable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let pictureUrl = dictionary["picture_url"] as? String,
              let type = dictionary["type"] as? Int,
              let createAt = dictionary["create_at"] as? Timestamp,
              let createBy = dictionary["create_by"] as? String,
              let modifiedAt = dictionary["modified_at"] as? Timestamp,
              let latestMessageDict = dictionary["latest_message"] as? [String: Any],
              let membersDict = dictionary["members"] as? [String: Any]
        else { return nil }

        var latestMessage = Message()

        if !latestMessageDict.isEmpty,
           let latestMessageId = latestMessageDict.keys.first,
           var latestMessageData = latestMessageDict.values.first as? [String: Any]
        {
            latestMessageData["id"] = latestMessageId
            latestMessage = Message(dictionary: latestMessageData) ?? Message()
        }

        let idOfMembers = membersDict.keys
        let dataOfMembers = idOfMembers.compactMap { memberId in
            if var memberData = membersDict[memberId] as? [String: Any] {
                memberData["id"] = memberId
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

        guard !members.isEmpty else {
            return nil
        }

        self.init(id: id,
                  name: name,
                  pictureUrl: pictureUrl,
                  type: type,
                  createAt: createAt.dateValue(),
                  createBy: createBy,
                  modifiedAt: modifiedAt.dateValue(),
                  latestMessage: latestMessage,
                  members: members)
    }
}
