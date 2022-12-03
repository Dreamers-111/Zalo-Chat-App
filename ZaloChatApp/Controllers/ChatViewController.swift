//
//  ChatViewController.swift
//  chatApp
//
//  Created by huy on 12/10/2022.
//

import InputBarAccessoryView
import MessageKit
import UIKit
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

class ChatViewController: MessagesViewController {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.timeZone = .current
        return formatter
    }()

    // MARK: Parameters - Data
    public let otherUserEmail: String
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
        self.otherUserEmail = otherUserInPrivateConvo.id
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
        self.otherUserEmail = conversation.id
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
        
        setupInputButton()
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
    
    //MARK: SEND MEDIA MESSAGE
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self]  _ in
            self?.presentVideoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self]  _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { selectedCoorindates in
            guard let messageId = self.createMessageId(),
                  let conversationId = self.conversation,
                  let selfSender = self.selfSender
            else {
                return
            }

            let longitude: Double = selectedCoorindates.longitude
            let latitude: Double = selectedCoorindates.latitude

            print("long=\(longitude) | lat= \(latitude)")

            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            
            let message = Message(messageId: messageId,
                                  kind: .location(location),
                                  sentDate: Date(),
                                  sender: selfSender,
                                  readBy: [""])
            
            DatabaseManager.shared.sendMessage(to: conversationId.id, message: message.kind) { error in
                guard error == nil else {
                    print("error send location", error as Any)
                    return
                }
                print("sent location message")
                /// Gửi tin nhắn đến cuộc hội thoại vừa tạo thành công
                /// Thì bắt đầu lắng nghe tất cả các tin nhắn của cuộc hội thoại đó
                self.startListeningForAllMessagesOfTheConversation(conversationId.id)
            }
            /// Bắt đầu lắng nghe cuộc hội thoại vừa tạo,
            /// Xảy ra đồng thời với việc gửi tin nhắn đi
            self.startListeningForChosenConveration(conversationId.id)
        }
        navigationController?.pushViewController(vc, animated: true)
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
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
    
    private func createMessageId() -> String? {
        // date, otherUesrEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "id") as? String else {
            return nil
        }

        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"

        print("created message id: \(newIdentifier)")

        return newIdentifier
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let conversationId = conversation,
              let selfSender = selfSender
        else {
            return
        }

        if let image = info[.editedImage] as? UIImage, let imageData =  image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            // Upload image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { result in
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(messageId: messageId,
                                          kind: .photo(media),
                                          sentDate: Date(),
                                          sender: selfSender,
                                          readBy: [""])
                    
                    DatabaseManager.shared.sendMessage(to: conversationId.id, message: message.kind) { error in
                        guard error == nil else {
                            print("error send photo", error as Any)
                            return
                        }
                        print("sent message photo: \(urlString)")
                        /// Gửi tin nhắn đến cuộc hội thoại vừa tạo thành công
                        /// Thì bắt đầu lắng nghe tất cả các tin nhắn của cuộc hội thoại đó
                        self.startListeningForAllMessagesOfTheConversation(conversationId.id)
                    }
                    /// Bắt đầu lắng nghe cuộc hội thoại vừa tạo,
                    /// Xảy ra đồng thời với việc gửi tin nhắn đi
                    self.startListeningForChosenConveration(conversationId.id)
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            })
        }
        
        if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            // Upload Video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { result in
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Video: \(urlString)")

                    guard let url = URL(string: urlString),
                        let placeholder = UIImage(systemName: "plus") else {
                            return
                    }

                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)

                    let message = Message(messageId: messageId,
                                          kind: .video(media),
                                          sentDate: Date(),
                                          sender: selfSender, readBy: [""])

                    DatabaseManager.shared.sendMessage(to: conversationId.id, message: message.kind) { error in
                        guard error == nil else {
                            print("error send video", error as Any)
                            return
                        }
                        print("sent message video: \(urlString)")
                        /// Gửi tin nhắn đến cuộc hội thoại vừa tạo thành công
                        /// Thì bắt đầu lắng nghe tất cả các tin nhắn của cuộc hội thoại đó
                        self.startListeningForAllMessagesOfTheConversation(conversationId.id)
                    }
                    /// Bắt đầu lắng nghe cuộc hội thoại vừa tạo,
                    /// Xảy ra đồng thời với việc gửi tin nhắn đi
                    self.startListeningForChosenConveration(conversationId.id)

                case .failure(let error):
                    print("message video upload error: \(error)")
                }
            })
        }
        else {
            print("lỗi rồi")
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)

            vc.title = "Location"
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else {
                return
            }

            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
