//
//  ViewControllerExtension.swift
//  camerafilterapp
//
//  Created by Ahmad Krisman Ryuzaki on 20/11/21.
//

import UIKit
import AVFoundation

extension ViewController {
    //MARK:- View Setup
    func setupView(){
        view.backgroundColor = .black
        view.addSubview(switchCameraButton)
        view.addSubview(captureImageButton)
        view.addSubview(capturedImageView)
        view.addSubview(filterListStackView)
        
        NSLayoutConstraint.activate([
            switchCameraButton.widthAnchor.constraint(equalToConstant: 30),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 30),
            switchCameraButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            switchCameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            captureImageButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureImageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            captureImageButton.widthAnchor.constraint(equalToConstant: 50),
            captureImageButton.heightAnchor.constraint(equalToConstant: 50),
            
            capturedImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            capturedImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            capturedImageView.heightAnchor.constraint(equalToConstant: 80),
            capturedImageView.widthAnchor.constraint(equalToConstant: 80),
            
            redFilterButton.heightAnchor.constraint(equalToConstant: 60),
            redFilterButton.widthAnchor.constraint(equalToConstant: 60),
            
            greenFilterButton.heightAnchor.constraint(equalToConstant: 60),
            greenFilterButton.widthAnchor.constraint(equalToConstant: 60),
            
            blueFilterButton.heightAnchor.constraint(equalToConstant: 60),
            blueFilterButton.widthAnchor.constraint(equalToConstant: 60),
        ])
        
        filterListStackView.addArrangedSubview(redFilterButton)
        filterListStackView.addArrangedSubview(greenFilterButton)
        filterListStackView.addArrangedSubview(blueFilterButton)
        
        switchCameraButton.addTarget(self, action: #selector(switchCamera(_:)), for: .touchUpInside)
        captureImageButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
    }
    
    //MARK:- Permissions
    func checkPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
                                                { (authorized) in
                if(!authorized){
                    abort()
                }
            })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
}
