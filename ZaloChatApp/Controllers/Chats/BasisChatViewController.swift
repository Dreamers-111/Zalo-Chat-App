//
//  BasisBasisChatViewController.swift
//  ZaloChatApp
//
//  Created by huy on 28/12/2022.
//

import AVKit
import CoreLocation
import Kingfisher
import MapKit
import MessageKit
import UIKit

class BasisChatViewController: MessagesViewController {
    enum State {
        case isNewPrivateConversation(User)
        case isExistingConversation(Conversation)
    }

    // MARK: Parameters - UIKit

    private let outgoingAvatarOverlap: CGFloat = 17.5

    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()

    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    internal lazy var audioController = MessageAudioController(messageCollectionView: messagesCollectionView)

    // MARK: Parameters - Data

    internal var state: State

    internal var messages = [Message]() {
        didSet(oldMessages) {
            switch state {
            case .isNewPrivateConversation:
                break
            case .isExistingConversation(let conversation):
                guard messages.count != oldMessages.count else {
                    break
                }
                listenForMessages(conversation.id, limitedToLast: messages.count)
            }
        }
    }

    internal var selfSender: User {
        return User(id: Defaults.currentUser[.id] ?? "",
                    name: Defaults.currentUser[.name] ?? "",
                    profilePictureUrl: Defaults.currentUser[.profilePictureUrl] ?? "",
                    isActive: true)
    }

    // MARK: Init

    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomMessageCollectionViewCell.self)
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        configureNavigationView()
        configureMessageCollectionView()
        configureMessageInputBar()

        switch state {
        case .isNewPrivateConversation(let otherUser):
            listenForOtherUser(otherUser.id)
        case .isExistingConversation(let conversation):
            listenForCurrentConveration(conversation.id)
            loadFirstMessages(conversation.id)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stopAnyOngoingPlaying()
    }

    // MARK: Methods - Listening for data

    internal func listenForOtherUser(_: String) {}

    internal func listenForCurrentConveration(_: String) {}

    internal func listenForMessages(_: String, limitedToLast _: Int) {}

    // MARK: Methods - Getting data

    internal func loadFirstMessages(_: String) {}

    @objc internal func loadMoreMessages() {}

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
        messagesCollectionView.messageCellDelegate = self

        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false

        messagesCollectionView.refreshControl = refreshControl

        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)

        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?
            .setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?
            .setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

        // Set outgoing avatar to overlap with the message bubble
        layout?
            .setMessageIncomingMessageTopLabelAlignment(LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?
            .setMessageIncomingMessagePadding(UIEdgeInsets(
                top: -outgoingAvatarOverlap,
                left: -18,
                bottom: outgoingAvatarOverlap,
                right: 18))

        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))

        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    internal func configureMessageInputBar() {
        // enable tap gesture for messageInputBar
        messagesCollectionView.isUserInteractionEnabled = true
        messageInputBar = CustomInputBarAccessoryView()
        inputBarType = .custom(messageInputBar)
    }

    internal func updateNavigationViewTitle() {
        switch state {
        case .isNewPrivateConversation(let otherUser):
            navigationItem.title = otherUser.displayName
        case .isExistingConversation(let conversation):
            navigationItem.title = conversation.displayName
        }
    }

    internal func insertMessageIntoMessagesCollectionView() {
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates {
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        } completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    internal func updateMessagesCollectionView() {
        messagesCollectionView.reloadDataAndKeepOffset()
    }

    // MARK: Methods - Helper

    private func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }

    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        /// Đảm bảo indexPath.section phải >= 1, vì khi bằng indexPath.section == 0
        /// Thì đó là tin nhắn đầu tiên và nó tất nhiên không có tin nhắn nào trước nó
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].user == messages[indexPath.section - 1].user
    }

    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        /// Đảm bảo indexPath.section phải < messages.count - 1
        /// Mà messages.count - 1 chính là số chỉ mục của phần tử cuối cùng trong mảng
        /// => indexPath.section phải là số chỉ mục của phần tử kế cuối trong mảng
        /// => Điều kiện đúng thật ra là:
        ///    messages.count > 1 và đồng thời indexPath.section > messages.count - 1
        /// Ví dụ : messages.count = 2, indexPath.section = 0
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].user == messages[indexPath.section + 1].user
    }

    private func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomMessageCollectionViewCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: MessagesDataSource

extension BasisChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return selfSender
    }

    func numberOfSections(in _: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in _: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                ])
        }
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(
                string: name,
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)])
        }
        return nil
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isNextMessageSameSender(at: indexPath), isFromCurrentSender(message: message) {
            return NSAttributedString(
                string: "Đã gửi",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }

    func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
        nil
    }
}

// MARK: MessagesLayoutDelegate

extension BasisChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for _: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
}

// MARK: MessagesDisplayDelegate

extension BasisChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) {
        let userProfilePictureUrl = (message as? Message)?.user.profilePictureUrl ?? ""
        avatarView.kf.setImage(with: URL(string: userProfilePictureUrl),
                               placeholder: UIImage(named: "default_avatar"))
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.mainColor.cgColor
    }

    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear

        switch message.kind {
        case .photo, .location:
            let button = UIButton(type: .infoLight)
            button.tintColor = .mainColor
            accessoryView.addSubview(button)
            button.frame = accessoryView.bounds
            button.isUserInteractionEnabled = true // respond to accessoryView tap through `MessageCellDelegate`
            accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        default:
            break
        }
    }

    // MARK: - Text Messages

    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(
        for detector: DetectorType,
        and message: MessageType,
        at _: IndexPath) -> [NSAttributedString.Key: Any]
    {
        switch detector {
        case .hashtag, .mention:
            if isFromCurrentSender(message: message) {
                return [.foregroundColor: UIColor.white]
            } else {
                return [.foregroundColor: UIColor.mainColor]
            }
        default:
            return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }

    // MARK: - All Messages

    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .mainColor : UIColor(red: 230 / 255,
                                                                     green: 230 / 255,
                                                                     blue: 230 / 255,
                                                                     alpha: 1)
    }

    func messageStyle(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        var corners: UIRectCorner = []

        corners.formUnion(.topLeft)
        corners.formUnion(.bottomLeft)
        corners.formUnion(.topRight)
        corners.formUnion(.bottomRight)

        return .custom { view in
            let radius: CGFloat = 14
            let path = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }

    // MARK: - Location Messages

    func annotationViewForLocation(message _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = UIImage(imageLiteralResourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }

    func animationBlockForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView) -> ((UIImageView) -> Void)?
    {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    view.layer.transform = CATransform3DIdentity
                },
                completion: nil)
        }
    }

    func snapshotOptionsForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView)
        -> LocationMessageSnapshotOptions
    {
        LocationMessageSnapshotOptions(
            showsBuildings: true,
            showsPointsOfInterest: true,
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Photo, Video Messages

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        switch message.kind {
        case .photo(let mediaItem):
            if let imageURL = mediaItem.url {
                imageView.kf.setImage(with: imageURL,
                                      placeholder: mediaItem.placeholderImage)
            } else {
                imageView.kf.cancelDownloadTask()
                imageView.image = mediaItem.placeholderImage
            }

        case .video(let mediaItem):
            let videoThumbnailPlaceholder = UIImage(imageLiteralResourceName: "video_message_thumbnail")
            if let videoURL = mediaItem.url {
                imageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 1),
                                      placeholder: videoThumbnailPlaceholder)
            } else {
                imageView.kf.cancelDownloadTask()
                imageView.image = videoThumbnailPlaceholder
            }
        default:
            break
        }
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .mainColor
    }

    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if case .audio(let audioItem) = message.kind {
            let audioURL = audioItem.url
            if audioURL.absoluteString != "file:///" {
                // then lets create your document folder url
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioURL.lastPathComponent)

                // to check if it exists before downloading it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    cell.activityIndicatorView.stopAnimating()
                    cell.playButton.isHidden = false

                    // if the file doesn't exist
                } else {
                    cell.activityIndicatorView.startAnimating()
                    cell.playButton.isHidden = true

                    // you can use NSURLSession.sharedSession to download the data asynchronously
                    URLSession.shared.downloadTask(with: audioURL, completionHandler: { location, _, error in
                        guard let location = location, error == nil else { return }
                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: location, to: destinationUrl)

                            DispatchQueue.main.async {
                                cell.activityIndicatorView.stopAnimating()
                                cell.playButton.isHidden = false
                            }

                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }).resume()
                }
            } else {
                cell.activityIndicatorView.startAnimating()
                cell.playButton.isHidden = true
            }
        }
        audioController.configureAudioCell(cell, message: message)
        // this is needed especially when the cell is reconfigure while is playing sound
    }
}

// MARK: MessageCellDelegate

extension BasisChatViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.section]

        switch message.kind {
        case .location(let locationData):
            let regionDistance: CLLocationDistance = 10000
            let coordinates = locationData.location.coordinate
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Vị trí hiện tại"
            mapItem.openInMaps(launchOptions: options)
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
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else { return }
            let player = AVPlayer(url: videoUrl)
            let vc = AVPlayerViewController()
            vc.player = player
            present(vc, animated: true) {
                player.play()
            }
        default:
            break
        }
    }

    func didTapPlayButton(in cell: AudioMessageCell) {
        guard cell.activityIndicatorView.isHidden == true,
              cell.playButton.isHidden == false
        else {
            print("Audio message hasn't been loaded yet.")
            return
        }

        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
