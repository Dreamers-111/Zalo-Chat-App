//
//  MessageAudioPlayerViewController.swift
//  ZaloChatApp
//
//  Created by huy on 26/12/2022.
//

import AVKit
import UIKit

protocol MessageAudioPlayerViewControllerDelegate {
    func didTapSendButton(withAudioUrl url: URL, duration: Float)
}

class MessageAudioPlayerViewController: UIViewController {
    // MARK: Paremeters - Data

    private var audioPlayer: AVAudioPlayer!
    private var timer: Timer?
    private var willContinuePlayingAfterDraggingProgessBar = false
    private let url: URL

    var delegate: MessageAudioPlayerViewControllerDelegate?

    // MARK: Parameters - UIKit

    private var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Trượt xuống để huỷ bỏ"
        label.textColor = .darkText
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var audioPlayerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 20
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .bottom
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layer.borderColor = UIColor.mainColor.cgColor
        stackView.layer.borderWidth = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // pause.fill
    private let playAndPauseButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btn.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Parameters - UIKit - timeLabelStackView

    private var timeLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .darkText
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .darkText
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var playerProgressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let progressBar: UISlider = {
        let progressBar = UISlider()
        progressBar.isContinuous = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()

    private var audioButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let backward5Button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "gobackward.5")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let forward5Button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "goforward.5")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let backward15Button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "gobackward.15")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let forward15Button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .medium
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "goforward.15")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.buttonSize = .large
        var attributedText = AttributedString("Gửi tin nhắn thoại")
        attributedText.font = .preferredFont(forTextStyle: .headline)
        config.attributedTitle = attributedText
        config.titleAlignment = .trailing
        config.imagePadding = 20
        config.baseBackgroundColor = .mainColor
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "paperplane.fill")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .leading
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btn.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let newRecordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "mic.fill.badge.plus")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btn.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Init

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Deinit

    deinit {
        timer?.invalidate()
        timer = nil
        audioPlayer.stop()
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()

        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(hintLabel)

        view.addSubview(timeLabelStackView)
        timeLabelStackView.addArrangedSubview(elapsedTimeLabel)
        timeLabelStackView.addArrangedSubview(remainingTimeLabel)

        view.addSubview(playerProgressStackView)
        playerProgressStackView.addArrangedSubview(progressBar)
        playerProgressStackView.addArrangedSubview(timeLabelStackView)

        view.addSubview(audioPlayerStackView)
        audioPlayerStackView.addArrangedSubview(playAndPauseButton)
        audioPlayerStackView.addArrangedSubview(playerProgressStackView)

        view.addSubview(audioButtonStackView)
        audioButtonStackView.addArrangedSubview(backward5Button)
        audioButtonStackView.addArrangedSubview(backward15Button)
        audioButtonStackView.addArrangedSubview(forward15Button)
        audioButtonStackView.addArrangedSubview(forward5Button)

        view.addSubview(sendButton)
        view.addSubview(newRecordButton)

        progressBar.addTarget(self, action: #selector(progressBarDragged(slider: event:)), for: .valueChanged)
        forward5Button.addTarget(self, action: #selector(didTapForward5Button(button:event:)), for: .touchUpInside)
        backward5Button.addTarget(self, action: #selector(didTapBackward5Button(button: event:)), for: .touchUpInside)
        forward15Button.addTarget(self, action: #selector(didTapForward15Button(button:event:)), for: .touchUpInside)
        backward15Button.addTarget(self, action: #selector(didTapBackward15Button(button: event:)), for: .touchUpInside)
        newRecordButton.addTarget(self, action: #selector(didTapNewRecordButton(button:event:)), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton(button:event:)), for: .touchUpInside)

        playAndPauseButton.configurationUpdateHandler = { [unowned self] button in
            // 1
            var config = button.configuration
            // 2
            if !audioPlayer.isPlaying {
                config?.baseForegroundColor = .white
                config?.image = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
                button.removeTarget(self, action: #selector(didTapPauseButton), for: .touchUpInside)
                button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
            } else {
                config?.baseForegroundColor = .white
                config?.image = UIImage(systemName: "pause.fill")?.withRenderingMode(.alwaysTemplate)
                button.removeTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
                button.addTarget(self, action: #selector(didTapPauseButton), for: .touchUpInside)
            }
            // 3
            button.configuration = config
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let constraints = [
            hintLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20),
            hintLabel.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            audioPlayerStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 30),
            audioPlayerStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -40),
            audioPlayerStackView.topAnchor.constraint(
                equalTo: hintLabel.bottomAnchor,
                constant: 30),
            audioPlayerStackView.heightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.25),

            timeLabelStackView.widthAnchor.constraint(
                equalTo: playerProgressStackView.widthAnchor),
            progressBar.widthAnchor.constraint(
                equalTo: playerProgressStackView.widthAnchor),

            playAndPauseButton.widthAnchor.constraint(
                equalTo: playAndPauseButton.heightAnchor),
            playAndPauseButton.heightAnchor.constraint(
                equalTo: audioPlayerStackView.layoutMarginsGuide.heightAnchor),

            audioButtonStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 50),
            audioButtonStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -50),
            audioButtonStackView.topAnchor.constraint(
                equalTo: audioPlayerStackView.bottomAnchor,
                constant: 20),

            newRecordButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 30),
            newRecordButton.trailingAnchor.constraint(
                equalTo: sendButton.leadingAnchor,
                constant: -30),
            sendButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -30),

            newRecordButton.topAnchor.constraint(
                equalTo: audioButtonStackView.bottomAnchor,
                constant: 40),
            sendButton.centerYAnchor.constraint(
                equalTo: newRecordButton.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        if audioPlayerStackView.layer.cornerRadius == Optional(CGFloat(0)),
           audioPlayerStackView.width != Optional(CGFloat(0))
        {
            audioPlayerStackView.layer.cornerRadius = audioPlayerStackView.width / 8
        }
    }

    // MARK: Methods - ObjectiveC

    @objc private func progressBarDragged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    timer?.invalidate()
                    timer = nil
                    willContinuePlayingAfterDraggingProgessBar = true
                } else {
                    willContinuePlayingAfterDraggingProgessBar = false
                }
            case .moved:
                let remainingtime = audioPlayer.duration - audioPlayer.currentTime
                remainingTimeLabel.text = remainingtime.stringFromTimeInterval()
                elapsedTimeLabel.text = audioPlayer.currentTime.stringFromTimeInterval()
            case .ended:
                audioPlayer.currentTime = TimeInterval(slider.value)
                if willContinuePlayingAfterDraggingProgessBar {
                    timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateProgressBar), userInfo: self, repeats: true)
                    audioPlayer.play()
                }
            default:
                break
            }
        }
        audioPlayer.currentTime = Float64(progressBar.value)
    }

    @objc private func didTapPlayButton(button: UIButton, event: UIEvent) {
        audioPlayer.play()
    }

    @objc private func didTapPauseButton(button: UIButton, event: UIEvent) {
        audioPlayer.stop()
    }

    @objc private func didTapForward5Button(button: UIButton, event: UIEvent) {
        let currentTime = audioPlayer.currentTime + 5
        if currentTime < audioPlayer.duration {
            audioPlayer.currentTime = currentTime
        } else {
            audioPlayer.stop()
            audioPlayer.currentTime = audioPlayer.duration
        }
    }

    @objc private func didTapBackward5Button(button: UIButton, event: UIEvent) {
        audioPlayer.currentTime -= 5
    }

    @objc private func didTapForward15Button(button: UIButton, event: UIEvent) {
        let currentTime = audioPlayer.currentTime + 15
        if currentTime < audioPlayer.duration {
            audioPlayer.currentTime = currentTime
        } else {
            audioPlayer.stop()
            audioPlayer.currentTime = audioPlayer.duration
        }
    }

    @objc private func didTapBackward15Button(button: UIButton, event: UIEvent) {
        audioPlayer.currentTime -= 15
    }

    @objc private func didTapNewRecordButton(button: UIButton, event: UIEvent) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapSendButton(button: UIButton, event: UIEvent) {
        delegate?.didTapSendButton(withAudioUrl: url,
                                   duration: Float(audioPlayer.duration))
        navigationController?.dismiss(animated: true)
    }

    // MARK: Methods - ObjectiveC -UI

    @objc private func updateProgressBar() {
        progressBar.value = Float(audioPlayer.currentTime)
        let remainingtime = audioPlayer.duration - audioPlayer.currentTime
        remainingTimeLabel.text = remainingtime.stringFromTimeInterval()
        elapsedTimeLabel.text = audioPlayer.currentTime.stringFromTimeInterval()
    }

    // MARK: Methods - Data

    private func setupAudioPlayer() {
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateProgressBar), userInfo: self, repeats: true)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            progressBar.minimumValue = 0
            progressBar.maximumValue = Float(audioPlayer.duration)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error on setting up the audio player: \(error.localizedDescription)")
            dismiss(animated: true)
        }
    }
}

extension MessageAudioPlayerViewController: AVAudioPlayerDelegate {}
