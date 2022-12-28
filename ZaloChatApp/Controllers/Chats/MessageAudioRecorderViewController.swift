//
//  MessageAudioRecorderViewController.swift
//  ZaloChatApp
//
//  Created by huy on 21/12/2022.
//

import AVKit
import UIKit

protocol MessageAudioRecorderViewControllerDelegate {
    func didFinishAudioRecordingToSendMessage(withAudioUrl url: URL, duration: Float)
}

class MessageAudioRecorderViewController: UIViewController {
    // MARK: Parameters - Data

    private var audioRecorder: AVAudioRecorder!
    private var timer: Timer?
    private var duration: Float = 0

    var delegate: MessageAudioRecorderViewControllerDelegate?
    private var didChooseToSendAfterRecordingAudio = true

    private var currentSoundSample = 0
    private var soundSamples = [Float](repeating: .zero, count: 10) {
        didSet {
            soundBarStackView.setNeedsLayout()
            soundBarStackView.layoutIfNeeded()
            let soundBarStackViewHeight = soundBarStackView.height

            if !soundBarViewInitialHeightConstraints.isEmpty {
                NSLayoutConstraint.deactivate(soundBarViewInitialHeightConstraints)
                soundBarViewInitialHeightConstraints.removeAll()
                soundBarStackView.setNeedsUpdateConstraints()
                soundBarStackView.updateConstraintsIfNeeded()
            }

            for (index, level) in soundSamples.enumerated() {
                let soundBarViewHeightRatio = normalizeSoundLevel(level: level)
                let soundBarViewHeight = soundBarStackViewHeight * soundBarViewHeightRatio

                UIView.animate(withDuration: 0.1) { [self] in
                    soundBarViewPrimaryHeightConstraints[index].constant = -(soundBarStackViewHeight - soundBarViewHeight)
                    soundBarStackView.setNeedsLayout()
                    soundBarStackView.layoutIfNeeded()
                }
            }
        }
    }

    private var soundBarViewPrimaryHeightConstraints = [NSLayoutConstraint]()
    private var soundBarViewInitialHeightConstraints = [NSLayoutConstraint]()

    // MARK: Parameters - UIKit

    private let defaultSoundLevel = Float(-45)
    private var defaultSoundBarViewHeightRatio: CGFloat {
        return normalizeSoundLevel(level: defaultSoundLevel)
    }

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Trượt xuống để huỷ ghi âm"
        label.textColor = .gray
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.textColor = .darkText
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let soundBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let microButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.title = nil
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .all
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        let btn = UIButton(configuration: config)
        btn.setContentHuggingPriority(.defaultLow, for: .vertical)
        btn.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let askToSendLabel: UILabel = {
        let label = UILabel()
        label.text = "Gửi sau khi kết thúc ghi âm"
        label.textColor = .gray
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label

    }()

    private let askToSendSwitch: UISwitch = {
        let swch = UISwitch()
        swch.setOn(true, animated: false)
        swch.preferredStyle = .automatic
        swch.setContentHuggingPriority(.defaultHigh, for: .vertical)
        swch.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        swch.translatesAutoresizingMaskIntoConstraints = false
        return swch
    }()

    // MARK: Init

    init() {
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
        audioRecorder.stop()
    }

    // MARK: Methods - Override

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioRecorder()

        view.backgroundColor = .white

        view.addSubview(hintLabel)
        view.addSubview(durationLabel)
        view.addSubview(soundBarStackView)

        // Tạo 10 thanh âm cho middleStackView
        for _ in 1 ... soundSamples.count {
            setupSoundBarView()
        }

        view.addSubview(microButton)
        view.addSubview(askToSendSwitch)
        view.addSubview(askToSendLabel)

        microButton.configurationUpdateHandler = { [unowned self] button in
            // 1
            var config = button.configuration
            // 2
            if !audioRecorder.isRecording {
                config?.baseForegroundColor = .white
                config?.image = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
                button.removeTarget(self, action: #selector(didTapMicroButtonToEndRecording), for: .touchUpInside)
                button.addTarget(self, action: #selector(didTapMicroButtonToStartRecording), for: .touchUpInside)
            } else {
                config?.baseForegroundColor = .systemRed
                config?.image = UIImage(systemName: "square.fill")?.withRenderingMode(.alwaysTemplate)
                button.removeTarget(self, action: #selector(didTapMicroButtonToStartRecording), for: .touchUpInside)
                button.addTarget(self, action: #selector(didTapMicroButtonToEndRecording), for: .touchUpInside)
            }
            // 3
            button.configuration = config
        }
        askToSendSwitch.addTarget(self, action: #selector(updateSendingOption), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let constraints = [
            hintLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20),
            hintLabel.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            durationLabel.topAnchor.constraint(
                equalTo: hintLabel.bottomAnchor,
                constant: 0),
            durationLabel.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            soundBarStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 30),
            soundBarStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -30),
            soundBarStackView.topAnchor.constraint(
                equalTo: durationLabel.bottomAnchor,
                constant: 20),
            soundBarStackView.bottomAnchor.constraint(
                equalTo: microButton.topAnchor,
                constant: -30),
            soundBarStackView.heightAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.35),

            microButton.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            microButton.widthAnchor.constraint(
                equalTo: microButton.heightAnchor),

            askToSendLabel.topAnchor.constraint(
                equalTo: microButton.bottomAnchor,
                constant: 5),
            askToSendLabel.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            askToSendSwitch.topAnchor.constraint(
                equalTo: askToSendLabel.bottomAnchor,
                constant: 5),
            askToSendSwitch.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: 0),
            askToSendSwitch.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
        NSLayoutConstraint.activate(constraints)

        if soundBarStackView.arrangedSubviews.randomElement()?.layer.cornerRadius == Optional(CGFloat(0)),
           soundBarStackView.arrangedSubviews.randomElement()?.width != Optional(CGFloat(0))
        {
            for soundBarView in soundBarStackView.arrangedSubviews {
                soundBarView.layer.cornerRadius = soundBarView.width / 4
            }
        }
    }

    // MARK: Methods - ObjectiveC

    @objc private func didTapMicroButtonToStartRecording() {
        startRecording()
    }

    @objc private func didTapMicroButtonToEndRecording() {
        timer?.invalidate()
        timer = nil
        audioRecorder.stop()
    }

    @objc private func updateSendingOption() {
        didChooseToSendAfterRecordingAudio = askToSendSwitch.isOn
    }

    // MARK: Methods - Data

    private func setupAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()

        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { [weak self]
                isGranted in
                    if !isGranted {
                        print("You must allow audio recording!")
                        self?.dismiss(animated: true)
                    }
            }
        }
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("Error on setting up the recorder: \(error.localizedDescription)")
            dismiss(animated: true)
        }

        // 2
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey: 32000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            // Class variable in order not to be kept alive
            let audioFilename = getDocumentsDirectory().appendingPathComponent("userAudioRecord.mp4")
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recorderSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: Methods - UI Configuration

    private func setupSoundBarView() {
        let soundBarView = UIView()
        soundBarView.backgroundColor = .mainColor
        soundBarView.translatesAutoresizingMaskIntoConstraints = false

        let initialHeightConstraint = soundBarView.heightAnchor.constraint(
            equalTo: soundBarStackView.heightAnchor,
            multiplier: defaultSoundBarViewHeightRatio,
            constant: 0)

        initialHeightConstraint.priority = .defaultHigh

        let primaryHeightConstraint = soundBarView.heightAnchor.constraint(
            equalTo: soundBarStackView.heightAnchor,
            multiplier: 1,
            constant: 0)

        primaryHeightConstraint.priority = .defaultLow

        soundBarStackView.addArrangedSubview(soundBarView)

        NSLayoutConstraint.activate([initialHeightConstraint, primaryHeightConstraint])

        soundBarViewPrimaryHeightConstraints.append(primaryHeightConstraint)
        soundBarViewInitialHeightConstraints.append(initialHeightConstraint)
    }

    // MARK: Methods - Helper

    private func startRecording() {
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] _ in
            audioRecorder.updateMeters()
            // soundBarStackView
            soundSamples[currentSoundSample] = audioRecorder.averagePower(forChannel: 0)
            currentSoundSample = (currentSoundSample + 1) % soundSamples.count

            // duration label
            durationLabel.text = audioRecorder.currentTime.stringFromTimeInterval()

            // duration
            duration = Float(audioRecorder.currentTime)
        }
    }

    private func normalizeSoundLevel(level: Float) -> CGFloat {
        /*
         Mức âm nhận được có giá trị dao động từ -160 đến 0.
         Chuyển đổi khoảng giá trị trên thành 1 đến 28.5.
         Trong đó mức âm thật sự là từ 1 trở lên.
         Mức âm 1 là mức âm mặc định khi chưa thu âm
         */

        /*
         Sau khi chuyển đổi giá trị mức âm, ta chia cho 28.5 để lấy tỉ lệ
         ,28.5 là giá trị cao nhất sau khi chuyển đổi mức âm
         ,tỉ lệ này sẽ được làm tỉ lệ về chiều cao.
         Tỉ lệ chiều cao giữa soundBarView so với soundBarStackView
         */

        // Kiểm tra nếu việc theo dõi độ cao của âm/ mức âm bắt đầu
        guard level < 0 else { return CGFloat(1 / 28.5) }
        let level = max(2, CGFloat(level) + 57) / 2
        return level / 28.5
    }

    func getDocumentsDirectory() -> URL {
        let urlList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urlList.first!
    }
}

extension MessageAudioRecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            if !didChooseToSendAfterRecordingAudio {
                let audioPlayer = MessageAudioPlayerViewController(url: recorder.url)
                audioPlayer.delegate = self
                navigationController?.pushViewController(audioPlayer, animated: true)
            } else {
                delegate?.didFinishAudioRecordingToSendMessage(withAudioUrl: recorder.url,
                                                               duration: duration)
                navigationController?.dismiss(animated: true)
            }
        }
    }
}

extension MessageAudioRecorderViewController: MessageAudioPlayerViewControllerDelegate {
    func didTapSendButton(withAudioUrl url: URL, duration: Float) {
        delegate?.didFinishAudioRecordingToSendMessage(withAudioUrl: url, duration: duration)
    }
}
