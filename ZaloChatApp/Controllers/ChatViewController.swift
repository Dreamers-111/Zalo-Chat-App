//
//  ChatViewController.swift
//  chatApp
//
//  Created by huy on 12/10/2022.
//

import InputBarAccessoryView
import MessageKit
import UIKit

class ChatViewController: MessagesViewController {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.timeZone = .current
        return formatter
    }()

    // MARK: Parameters - Data

    private var isNewPrivateConversation = false
    private var conversation: Conversation?
    private var otherUserInPrivateConvo: User?
    private var displayName: String
    private var displayPictureUrl: String
    private var messages = [Message]()

    private let dummySelfSender = User(id: "dummyId169", name: "dummy", profilePictureUrl: "dummy", isActive: true)

    private let selfSender: User? = {
        guard let currentUserId = UserDefaults.standard.value(forKey: "id") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String,
              let currentUserPictureUrl = UserDefaults.standard.value(forKey: "profile_picture_url") as? String
        else {
            print("Thất bại lấy thông tin người dùng hiện tại, được lưu trong bộ nhớ đệm")
            return nil
        }
        return User(id: currentUserId, name: currentUserName, profilePictureUrl: currentUserPictureUrl, isActive: true)
    }()

    // MARK: Init

    /// Hàm khởi tạo được dùng khi cuộc hội thoại chưa có
    /// Là bước chuẩn bị để tạo cuộc hội thoại trên csdl nếu người dùng hiện tại nhắn tin nhắn đầu tiên
    init(otherUserInPrivateConvo: User) {
        self.isNewPrivateConversation = true
        //
        self.conversation = nil
        self.otherUserInPrivateConvo = otherUserInPrivateConvo
        //
        self.displayName = otherUserInPrivateConvo.name
        self.displayPictureUrl = otherUserInPrivateConvo.profilePictureUrl
        super.init(nibName: nil, bundle: nil)
    }

    init(conversation: Conversation) {
        self.isNewPrivateConversation = false
        //
        self.conversation = conversation
        self.otherUserInPrivateConvo = nil
        //
        self.displayName = conversation.displayName
        self.displayPictureUrl = conversation.displayPictureUrl
        super.init(nibName: nil, bundle: nil)

        startListeningForChosenConveration(conversation.id)
        startListeningForAllMessagesOfTheConversation(conversation.id)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = displayName
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DatabaseManager.shared.removeListenersForChatViewController()
    }

    // MARK: Methods - Data

    private func startListeningForChosenConveration(_ conversationId: String) {
        DatabaseManager.shared.listenForConversation(with: conversationId) { [weak self] result in
            switch result {
            case .success(let conversation):
                self?.isNewPrivateConversation = false
                self?.otherUserInPrivateConvo = nil
                self?.conversation = conversation
                self?.displayName = conversation.displayName
                self?.displayPictureUrl = conversation.displayPictureUrl
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            case .failure(let error):
                print("failed to listen for specific conversation", error)
            }
        }
    }

    private func startListeningForAllMessagesOfTheConversation(_ conversationId: String) {
        DatabaseManager.shared.listenForAllMessages(ofConvoWithId: conversationId) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            case .failure(let error):
                print("failed to listen for all messages of conversation", error)
            }
        }
    }

    // MARK: Methods - UI

    private func updateUI() {
        navigationItem.title = displayName
        messagesCollectionView.reloadData()
    }
}

// MARK: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender ?? dummySelfSender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }

        /// Nếu đây là cuộc hội thoại mới,
        /// và có thông tin người dùng còn lại trong cuộc hội thoại riêng tư được truyền vào
        if isNewPrivateConversation, let otherUserInPrivateConvo = otherUserInPrivateConvo {
            DatabaseManager.shared.createNewPrivateConversation(with: otherUserInPrivateConvo)
                { [weak self] result in
                    switch result {
                    /// Nếu tạo cuộc hội thoại mới thành công thì
                    case .success(let conversationId):
                        /// Gửi tin nhắn đến cuộc hội thoại vừa tạo
                        DatabaseManager.shared.sendMessage(to: conversationId, message: .text(text)) { error in
                            guard error == nil else {
                                print("Thất bại gửi tin nhắn đến cuộc hội thoại riêng tư mới vừa tạo", error as Any)
                                return
                            }
                            /// Gửi tin nhắn đến cuộc hội thoại vừa tạo thành công
                            /// Thì bắt đầu lắng nghe tất cả các tin nhắn của cuộc hội thoại đó
                            self?.startListeningForAllMessagesOfTheConversation(conversationId)
                        }
                        /// Bắt đầu lắng nghe cuộc hội thoại vừa tạo,
                        /// Xảy ra đồng thời với việc gửi tin nhắn đi
                        self?.startListeningForChosenConveration(conversationId)
                    case .failure(let error):
                        print("Thất bại tạo một cuộc hội thoại riêng tư mới", error)
                    }
                }
        }
        else if !isNewPrivateConversation, let conversation = conversation {
            // send message to existing conversation
            DatabaseManager.shared.sendMessage(to: conversation.id, message: .text(text)) { error in
                guard error == nil else {
                    print("Thất bại gửi tin nhắn đến cuộc hội thoại riêng đã tồn tại", error as Any)
                    return
                }
            }
        }
    }
}
