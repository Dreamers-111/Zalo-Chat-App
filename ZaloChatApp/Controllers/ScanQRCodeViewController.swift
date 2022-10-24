//
//  ScanQRCodeViewController.swift
//  ZaloChatApp
//
//  Created by geotech on 21/10/2022.
//

import Foundation
import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController {
    
    var captureSession: AVCaptureSession? = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var isReading: Bool?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan QR code"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        setUpBottomControls()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerQR)
        contentView.addSubview(scanButton)
        contentView.addSubview(qrCodeTextField)
        
        scanButton.addTarget(self, action: #selector(didTapScanQRCode), for: .touchUpInside)
        isReading = false
        captureSession = nil
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
            
            containerQR.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            containerQR.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/3),
            containerQR.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerQR.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            scanButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            scanButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            scanButton.topAnchor.constraint(equalTo: containerQR.bottomAnchor, constant: 30),
            scanButton.heightAnchor.constraint(equalTo: qrCodeTextField.heightAnchor, multiplier: 1.1),
            
            qrCodeTextField.topAnchor.constraint(equalTo: scanButton.bottomAnchor,constant: 30),
            qrCodeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            qrCodeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
        ])
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
        button.setTitle("Sao chép", for: .normal)
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
        button.setTitle("Mở liên kết", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        button.tintColor = .link
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        return button
     }()
    
    fileprivate func setUpBottomControls() {
        let button = UIStackView(arrangedSubviews: [openLinkButton, copyButton])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.distribution = .equalCentering
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
        ])
    }
    
    private var qrCodeTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Đang tìm..."
        field.setFieldLoginAndRegister()
        return field
    }()
    
    @objc private func didTapScanQRCode() {

         if (isReading == false) {
             print("start")
             self.startReading()

         } else {
             print("no")
             captureSession?.stopRunning()

             captureSession = nil;

             videoPreviewLayer?.removeFromSuperlayer()
         }
     }
    
    func startReading() -> Bool {

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {

            print("Failed to get the camera device")

            return false
        }
        do {

            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession?.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()

            captureSession?.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)

            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill

            videoPreviewLayer?.frame = containerQR.layer.bounds

            containerQR.layer.addSublayer(videoPreviewLayer!)

            DispatchQueue.main.async {
                self.captureSession?.startRunning()
            }
        
        } catch {

            print(error)

            return false

        }
        
        return true
    }
}

extension ScanQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {

            return
        }
            
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            
            qrCodeTextField.text = metadataObj.stringValue
            
            isReading = false
        }
    }
}


//            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
