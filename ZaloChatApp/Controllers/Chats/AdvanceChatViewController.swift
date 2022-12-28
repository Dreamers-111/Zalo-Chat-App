//
//  AdvanceChatViewController.swift
//  ZaloChatApp
//
//  Created by huy on 28/12/2022.
//
import CoreLocation
import FirebaseFirestore
import InputBarAccessoryView
import MessageKit
import UIKit

typealias ChatViewController = AdvanceChatViewController
class AdvanceChatViewController: BasisChatViewController {
    private let db = DatabaseManager.shared

    // MARK: Parameters - Listener

    private var otherUserListener: ListenerRegistration?
    private var currentConversationListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?

    deinit {
        if currentConversationListener?.remove() != nil {
            currentConversationListener = nil
        }

        if otherUserListener?.remove() != nil {
            otherUserListener = nil
        }

        if messagesListener?.remove() != nil {
            messagesListener = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func configureMessageInputBar() {
        super.configureMessageInputBar()
        messageInputBar.delegate = self
    }

    override func listenForOtherUser(_ otherUserId: String) {
        // Tự động huỷ listener lắng nghe người dùng khác trước đó
        if otherUserListener?.remove() != nil {
            otherUserListener = nil
        }

        // Tự động huỷ listner lắng nghe cuộc hội thoại hiện tại vì chỉ 1 trong 2 listener này được chạy
        if currentConversationListener?.remove() != nil {
            currentConversationListener = nil
        }

        otherUserListener = db.listenForUser(with: otherUserId) { [weak self] result in
            switch result {
            case .success(let otherUser):
                self?.state = .isNewPrivateConversation(otherUser)
                DispatchQueue.main.async {
                    self?.updateNavigationViewTitle()
                }
            case .failure(let error):
                print("failed to listen for other user", error)
            }
        }
    }

    override func listenForCurrentConveration(_ conversationId: String) {
        // Tự động huỷ listner lắng nghe cuộc hội thoại hiện tại trước đó
        if currentConversationListener?.remove() != nil {
            currentConversationListener = nil
        }

        // Tự động huỷ listener lắng nghe người dùng khác vì chỉ 1 trong 2 listener này được chạy
        if otherUserListener?.remove() != nil {
            otherUserListener = nil
        }

        currentConversationListener = db.listenForConversation(with: conversationId) { [weak self] result in
            switch result {
            case .success(let conversation):
                self?.state = .isExistingConversation(conversation)
                DispatchQueue.main.async {
                    self?.updateNavigationViewTitle()
                }
            case .failure(let error):
                print("failed to listen for current conversation", error)
            }
        }
    }

    override func listenForMessages(_ conversationId: String,
                                    limitedToLast limit: Int)
    {
        // Tự động huỷ listener lắng nghe các tin nhắn của cuộc hội thoại trước đó
        if messagesListener?.remove() != nil {
            messagesListener = nil
        }

        print(limit)

        messagesListener = db.listenForMessages(ofConversation: conversationId,
                                                limitedToLast: limit) { [weak self] result in
            switch result {
            case .success(let messages):
                // messages truyền vô đây luôn khác rỗng
                let serverLatestMessage = messages[messages.count - 1]
                var thereIsANewMessage: Bool
                // Nên nếu phía client có tin nhắn thì so sánh tin nhắn mới nhất giữa 2 phía client và server để biết có một tin nhắn mới hay không
                if let clientLatestMessage = self?.messages.last {
                    thereIsANewMessage = (clientLatestMessage != serverLatestMessage) && (clientLatestMessage.sentDate < serverLatestMessage.sentDate)
                }
                // Còn phía client không có tin nhắn, thì chắc chắn có một tin nhắn mới vì messages truyền vô không bao giờ rỗng
                else {
                    thereIsANewMessage = true
                }

                if thereIsANewMessage {
                    self?.messages.append(serverLatestMessage)
                    DispatchQueue.main.async {
                        self?.insertMessageIntoMessagesCollectionView()
                    }
                } else {
                    self?.messages = messages
                    DispatchQueue.main.async {
                        self?.updateMessagesCollectionView()
                    }
                }
            case .failure(let error):
                print("failed to listen for messages of current conversation", error)
            }
        }
    }

    override func loadFirstMessages(_ conversationId: String) {
        db.getMessages(ofConversation: conversationId, limitedToLast: 15) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem(animated: false)
                }
            case .failure(let error):
                print("failed to get first 15 messages of current conversation", error)
            }
        }
    }

    override func loadMoreMessages() {
        switch state {
        case .isNewPrivateConversation:
            break
        case .isExistingConversation(let conversation):
            db.getMessages(ofConversation: conversation.id, limitedToLast: messages.count + 15) { [weak self] result in
                switch result {
                case .success(let messages):
                    self?.messages = messages
                    DispatchQueue.main.async {
                        self?.messagesCollectionView.reloadDataAndKeepOffset()
                        self?.refreshControl.endRefreshing()
                    }
                case .failure(let error):
                    print("failed to get more messages of current conversation", error)
                }
            }
        }
    }

    private func sendMessage(ofKind messageKind: MessageKind) {
        switch state {
        case .isNewPrivateConversation(let otherUser):
            db.createNewPrivateConversation(with: otherUser) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    self?.listenForCurrentConveration(conversationId)
                    self?.listenForMessages(conversationId, limitedToLast: 15)
                    sendMessage(to: conversationId,
                                errorMessage: "Thất bại gửi tin nhắn đến cuộc hội thoại vừa mới tạo.")
                case .failure(let error):
                    print("Thất bại tạo một cuộc hội thoại riêng tư mới", error)
                }
            }
        case .isExistingConversation(let conversation):
            sendMessage(to: conversation.id,
                        errorMessage: "Thất bại gửi tin nhắn đến cuộc hội thoại đã tồn tại.")
        }

        func sendMessage(to conversationId: String, errorMessage message: String) {
            let completion: (DatabaseManager.DatabaseError?) -> Void = { [weak self] error in
                guard error == nil else {
                    print(message, error!)
                    return
                }
                DispatchQueue.main.async {
                    self?.messageInputBar.sendButton.stopAnimating()
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
            switch messageKind {
            case .text(let text):
                db.sendTextMessage(to: conversationId,
                                   sender: selfSender,
                                   text: text,
                                   completion: completion)
            case .photo(let photoItem):
                db.sendPhotoMessage(to: conversationId,
                                    sender: selfSender,
                                    photoItem: photoItem,
                                    completion: completion)
            case .video(let videoItem):
                db.sendVideoMessage(to: conversationId,
                                    sender: selfSender,
                                    videoItem: videoItem,
                                    completion: completion)
            case .location(let locationItem):
                db.sendLocationMessage(to: conversationId,
                                       sender: selfSender,
                                       locationItem: locationItem,
                                       completion: completion)
            case .audio(let audioItem):
                db.sendAudioMessage(to: conversationId,
                                    sender: selfSender,
                                    audioItem: audioItem,
                                    completion: completion)
            default:
                print("unsupported message kind!")
            }
        }
    }
}

// MARK: Methods - Mở hoặc chuyển tiếp sang các view controller lấy dữ liệu đầu vào

extension AdvanceChatViewController {
    private func presentMediaPickerController(sourceType: UIMediaPickerController.SourceType) {
        let mediaPicker = UIMediaPickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.sourceType = sourceType
        if let mediaTypes = UIMediaPickerController.availableMediaTypes(for: sourceType) {
            mediaPicker.mediaTypes = mediaTypes
        }
        mediaPicker.videoQuality = .typeHigh

        if sourceType == .photoLibrary, let sheet = mediaPicker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = false
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = false
        }
        navigationController?.present(mediaPicker, animated: true)
    }

    private func presentAudioRecorderViewController() {
        let audioRecorderViewController = MessageAudioRecorderViewController()
        audioRecorderViewController.delegate = self
        let nav = UINavigationController(rootViewController: audioRecorderViewController)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 24
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = false
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = false
        }
        present(nav, animated: true)
    }

    private func pushLocationPickerController() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.completion = { [weak self] selectedCoorindates in
            let longitude = selectedCoorindates.longitude
            let latitude = selectedCoorindates.latitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinateItem = MessageCoordinateItem(location: location)
            self?.sendMessage(ofKind: .location(coordinateItem))
            self?.messageInputBar.sendButton.startAnimating()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension AdvanceChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    typealias UIMediaPickerController = UIImagePickerController

    func imagePickerController(_ picker: UIMediaPickerController, didFinishPickingMediaWithInfo info: [UIMediaPickerController.InfoKey: Any]) {
        guard let mediaType = info[.mediaType] as? NSString else {
            picker.dismiss(animated: true)
            return
        }
        switch mediaType {
        case NSString(string: "public.image"):
            if let editedImage = info[.editedImage] as? UIImage {
                messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
            } else if let originImage = info[.originalImage] as? UIImage {
                messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
            }
        case NSString(string: "public.movie"):
            if let videoUrl = info[.mediaURL] as? URL {
                let videoItem = MessageMediaItem(imageURL: videoUrl)
                sendMessage(ofKind: .video(videoItem))
                messageInputBar.sendButton.startAnimating()
            }
        default:
            break
        }

        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIMediaPickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: CustomInputBarAccessoryViewDelegate

extension AdvanceChatViewController: CustomInputBarAccessoryViewDelegate {
    func didPressCameraBtn() {
        presentMediaPickerController(sourceType: .camera)
    }

    func didPressPhotoLibraryBtn() {
        audioController.stopAnyOngoingPlaying()
        presentMediaPickerController(sourceType: .photoLibrary)
    }

    func didPressMicroBtn() {
        audioController.stopAnyOngoingPlaying()
        presentAudioRecorderViewController()
    }

    func didPressMapPinBtn() {
        pushLocationPickerController()
    }

    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String)
    {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        sendMessage(ofKind: .text(text))
        inputBar.inputTextView.text = String()
        inputBar.sendButton.startAnimating()
    }

    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith attachments: [AttachmentManager.Attachment])
    {
        attachments.forEach { attachment in
            if case .image(let image) = attachment {
                let imageItem = MessageMediaItem(image: image)
                sendMessage(ofKind: .photo(imageItem))
            }
        }
        inputBar.invalidatePlugins()
        inputBar.sendButton.startAnimating()
    }
}

extension AdvanceChatViewController: MessageAudioRecorderViewControllerDelegate {
    func didFinishAudioRecordingToSendMessage(withAudioUrl url: URL, duration: Float) {
        let audioItem = MessageAudioItem(audioURL: url, duration: duration)
        sendMessage(ofKind: .audio(audioItem))
        messageInputBar.sendButton.startAnimating()
    }
}
