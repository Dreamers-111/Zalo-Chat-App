//
//  ChatViewController.swift
//  chatApp
//
//  Created by huy on 12/10/2022.
//

import AVKit
import CoreLocation
import FirebaseFirestore
import InputBarAccessoryView
import Kingfisher
import MessageKit
import UIKit

/// Dùng để mô tả đơn giản người gửi hiện tại trong ChatViewController
private struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    private let db = DatabaseManager.shared

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    enum State {
        case isNewPrivateConversation(User)
        case isExistingConversation(Conversation)
    }

    // MARK: Listeners

    private var otherUserListener: ListenerRegistration?
    private var currentConversationListener: ListenerRegistration?
    private var allMessagesListener: ListenerRegistration?

    // MARK: Parameters - UiKit

    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    private lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    // MARK: Parameters - Data

    private var state: State

    private var messages = [Message]()

    private var selfSender: SenderType {
        guard let currentUserId = Defaults.currentUser[.id],
              let currentUserName = Defaults.currentUser[.name]
        else {
            return Sender(senderId: "", displayName: "")
        }
        return Sender(senderId: currentUserId, displayName: currentUserName)
    }

    // MARK: Init

    /// Hàm khởi tạo được dùng khi cuộc hội thoại chưa có
    /// Là bước chuẩn bị để tạo cuộc hội thoại trên csdl nếu người dùng hiện tại nhắn tin nhắn đầu tiên
    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
        //
        switch state {
        case .isNewPrivateConversation(let otherUser):
            startListeningForOtherUser(otherUser.id)
        case .isExistingConversation(let conversation):
            startListeningForCurrentConveration(conversation.id)
            startListeningForAllMessagesOfTheConversation(conversation.id)
        }
        //
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: Deinit

    deinit {
        audioController.stopAnyOngoingPlaying()

        if currentConversationListener?.remove() != nil {
            currentConversationListener = nil
        }

        if otherUserListener?.remove() != nil {
            otherUserListener = nil
        }

        if allMessagesListener?.remove() != nil {
            allMessagesListener = nil
        }
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureNavigationView()
        configureMessageCollectionView()
        configureMessageInputBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

    @objc
    func loadMoreMessages() {}

    // MARK: Methods - Data

    private func startListeningForOtherUser(_ otherUserId: String) {
        if currentConversationListener?.remove() != nil {
            currentConversationListener = nil
        }

        otherUserListener = db.listenForUser(with: otherUserId) { [weak self] result in
            switch result {
            case .success(let otherUser):
                self?.state = .isNewPrivateConversation(otherUser)
                DispatchQueue.main.async {
                    self?.updateTitle()
                }
            case .failure(let error):
                print("failed to listen for other user", error)
            }
        }
    }

    private func startListeningForCurrentConveration(_ conversationId: String) {
        if otherUserListener?.remove() != nil {
            otherUserListener = nil
        }

        currentConversationListener = db.listenForConversation(with: conversationId) { [weak self] result in
            switch result {
            case .success(let conversation):
                self?.state = .isExistingConversation(conversation)
                DispatchQueue.main.async {
                    self?.updateTitle()
                }
            case .failure(let error):
                print("failed to listen for current conversation", error)
            }
        }
    }

    private func startListeningForAllMessagesOfTheConversation(_ conversationId: String) {
        allMessagesListener = db.listenForAllMessages(ofConvoWithId: conversationId) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.updateMessagesCollectionView()
                }
            case .failure(let error):
                print("failed to listen for all messages of current conversation", error)
            }
        }
    }

    // MARK: Methods - UI

    private func configureNavigationView() {
        switch state {
        case .isNewPrivateConversation(let otherUser):
            navigationItem.title = otherUser.displayName
        case .isExistingConversation(let conversation):
            navigationItem.title = conversation.displayName
        }
        navigationItem.largeTitleDisplayMode = .never
    }

    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        showMessageTimestampOnSwipeLeft = true // default false

        messagesCollectionView.refreshControl = refreshControl
    }

    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .mainColor
        messageInputBar.sendButton.setTitleColor(.mainColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(.mainColor.withAlphaComponent(0.3), for: .highlighted)
        setupMessageInputButton()
    }

    private func setupMessageInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    private func updateMessagesCollectionView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: false)
    }

    private func updateTitle() {
        switch state {
        case .isNewPrivateConversation(let otherUser):
            navigationItem.title = otherUser.displayName
        case .isExistingConversation(let conversation):
            navigationItem.title = conversation.displayName
        }
    }

    // MARK: Methods - Helper

    private func sendMessage(ofKind messageKind: MessageKind) {
        func sendMessage(to conversationId: String, errorHandlerMessage message: String) {
            let errorHandler: (DatabaseManager.DatabaseError?) -> Void = {
                [weak self] error in
                guard error == nil else {
                    print(message, error!)
                    return
                }
            }
            switch messageKind {
            case .text(let text):
                db.sendTextMessage(to: conversationId,
                                   text: text,
                                   completion: errorHandler)
            case .photo(let photoItem):
                db.sendPhotoMessage(to: conversationId,
                                    photoItem: photoItem,
                                    completion: errorHandler)
            case .video(let videoItem):
                db.sendVideoMessage(to: conversationId,
                                    videoItem: videoItem,
                                    completion: errorHandler)
            case .location(let locationItem):
                db.sendLocationMessage(to: conversationId,
                                       locationItem: locationItem,
                                       completion: errorHandler)
            default:
                print("unsupported message kind!")
            }
        }
        switch state {
        case .isNewPrivateConversation(let otherUser):
            db.createNewPrivateConversation(with: otherUser) { [weak self] result in
                switch result {
                case .success(let conversationId):
                    self?.startListeningForCurrentConveration(conversationId)
                    self?.startListeningForAllMessagesOfTheConversation(conversationId)
                    sendMessage(to: conversationId,
                                errorHandlerMessage: "Thất bại gửi tin nhắn đến cuộc hội thoại vừa mới tạo.")
                case .failure(let error):
                    print("Thất bại tạo một cuộc hội thoại riêng tư mới", error)
                }
            }
        case .isExistingConversation(let conversation):
            sendMessage(to: conversation.id,
                        errorHandlerMessage: "Thất bại gửi tin nhắn đến cuộc hội thoại đã tồn tại.")
        }
    }

    // MARK: SEND MEDIA MESSAGE

    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionsheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
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
        vc.completion = { [weak self] selectedCoorindates in
            let longitude = selectedCoorindates.longitude
            let latitude = selectedCoorindates.latitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let coordinateItem = MessageCoordinateItem(location: location)
            self?.sendMessage(ofKind: .location(coordinateItem))
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let photoItem):
            guard let photoUrl = photoItem.url else {
                imageView.image = photoItem.placeholderImage
                return
            }
            imageView.kf.setImage(with: photoUrl, placeholder: photoItem.placeholderImage)
        default:
            break
        }
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let userProfilePictureUrl = messages[indexPath.section].user.profilePictureUrl
        avatarView.kf.setImage(with: URL(string: userProfilePictureUrl),
                               placeholder: UIImage(named: "default_avatar"))
    }

    func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
        NSAttributedString(
            string: "Read",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            ])
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = messages[indexPath.section].user.name
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    func textCellSizeCalculator(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CellSizeCalculator? {
        nil
    }
}

// MARK: InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        sendMessage(ofKind: .text(text))
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.editedImage] as? UIImage {
            let photoItem = MessageImageMediaItem(image: image)
            sendMessage(ofKind: .photo(photoItem))
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let videoItem = MessageImageMediaItem(imageURL: videoUrl)
            sendMessage(ofKind: .video(videoItem))
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
