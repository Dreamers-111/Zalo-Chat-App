//
//  ScanQRCodeViewController.swift
//  ZaloChatApp
//
//  Created by Phan Tâm Như on 21/10/2022.
//

import AVFoundation
import UIKit

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan QR code"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        scanButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        openLinkButton.addTarget(self, action: #selector(openlink), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyText), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)

        captureSession = AVCaptureSession()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerQR)
        contentView.addSubview(scanButton)
        contentView.addSubview(qrCodeTextField)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(openLinkButton)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func dismissSelf() {
        navigationController?.dismiss(animated: true)
    }
    
    private let scrollView: UIScrollView = {
         let scrollView = UIScrollView()
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         scrollView.isScrollEnabled = true
         return scrollView
     }()

     private let contentView: UIView = {
         var contentView = UIView()
         contentView.translatesAutoresizingMaskIntoConstraints = false
         return contentView
     }()
     
     private let containerQR: UIView = {
         let container = UIView()
         container.translatesAutoresizingMaskIntoConstraints = false
         container.backgroundColor = .gray
         return container
     }()
     
     private let scanButton: UIButton = {
         let button = UIButton()
         button.translatesAutoresizingMaskIntoConstraints = false
         button.setTitle("Quét mã", for: .normal)
         button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
         button.tintColor = .white
         button.backgroundColor = UIColor(red: 0.90, green: 0.00, blue: 0.21, alpha: 1.00)
         button.layer.cornerRadius = 15
         // Shadow Color
         button.layer.shadowColor = UIColor(red: 1.00, green: 0.59, blue: 0.69, alpha: 1.00).cgColor
         button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
         button.layer.shadowOpacity = 1
         button.layer.shadowRadius = 1
         button.layer.masksToBounds = false
         return button
      }()
     
     private let openLinkButton: UIButton = {
         var filled = UIButton.Configuration.borderless()
         filled.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 8)
         let button = UIButton(configuration: filled, primaryAction: nil)
         button.translatesAutoresizingMaskIntoConstraints = false
         button.setTitle("Mở liên kết", for: .normal)
         button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
         button.tintColor = .link
         button.backgroundColor = .clear
         button.layer.cornerRadius = 15
         button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
         return button
      }()
     
     private let copyButton: UIButton = {
         var filled = UIButton.Configuration.borderless()
         filled.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 8)
         let button = UIButton(configuration: filled, primaryAction: nil)
         button.translatesAutoresizingMaskIntoConstraints = false
         button.setTitle("Sao chép", for: .normal)
         button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
         button.tintColor = .link
         button.backgroundColor = .clear
         button.layer.cornerRadius = 15
         return button
      }()
     
     private let buttonStackView: UIStackView = {
         var buttonStackView = UIStackView()
         buttonStackView.translatesAutoresizingMaskIntoConstraints = false
         buttonStackView.axis = .horizontal
         buttonStackView.distribution = .equalSpacing
         return buttonStackView
     }()
     
     private var qrCodeTextField: UITextField = {
         let field = UITextField()
         field.placeholder = "Đang tìm..."
         field.setFieldLoginAndRegister()
         return field
     }()
    
    @objc private func openCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = containerQR.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        containerQR.layer.addSublayer(previewLayer)

        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
    }

    private func failed() {
        let ac = UIAlertController(title: "Thiết bị này không được hỗ trợ", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Đồng ý", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            qrCodeTextField.text = stringValue
            previewLayer.removeFromSuperlayer()
        }

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            captureSession = nil
        }
    }
    
    @objc private func openlink() {
        if let url = URL(string: qrCodeTextField.text ?? "") {
           if #available(iOS 10, *){
               UIApplication.shared.open(url)
           } else{
               UIApplication.shared.openURL(url)
           }
        } else {
            alertError(message: "Liên kết không tồn tại")
        }
    }
    
    func alertError(message: String) {
        let alert = UIAlertController(title: message,
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Đồng ý",
                                      style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc private func copyText() {
        if (qrCodeTextField.text == "") {
            alertError(message: "Không tìm thấy nội dung")
        } else {
            UIPasteboard.general.string = qrCodeTextField.text
            qrCodeTextField.text = ""
            copyButton.setTitle("Đã sao chép", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.copyButton.setTitle("Sao chép", for: .normal)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: buttonStackView.bottomAnchor),
            
            containerQR.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            containerQR.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),
            containerQR.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerQR.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            scanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            scanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            scanButton.topAnchor.constraint(equalTo: containerQR.bottomAnchor, constant: 30),
            scanButton.heightAnchor.constraint(equalTo: qrCodeTextField.heightAnchor, multiplier: 1.1),
            
            qrCodeTextField.topAnchor.constraint(equalTo: scanButton.bottomAnchor,constant: 30),
            qrCodeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            qrCodeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            
            buttonStackView.topAnchor.constraint(equalTo: qrCodeTextField.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}
