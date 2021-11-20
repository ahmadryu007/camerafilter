//
//  ViewController.swift
//  camerafilterapp
//
//  Created by Ahmad Krisman Ryuzaki on 20/11/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var captureSession : AVCaptureSession!
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var videoOutput : AVCaptureVideoDataOutput!
    
    var takePicture = false
    var backCameraOn = true
    
    var selectedFilter: UIColor? = nil
    
    lazy var filterListStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: (self.view.frame.width / 2) - 110, y: self.view.frame.height - 200, width: 220, height: 60))
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        
        return stackView
    }()
    
    lazy var redFilterButton: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(redFilterApply))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    lazy var greenFilterButton: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(greenFilterApply))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    lazy var blueFilterButton: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(blueFilterApply))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    let switchCameraButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "switchcamera")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let captureImageButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let capturedImageView = CapturedImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermissions()
        setupAndStartCaptureSession()
    }
    
    @objc func redFilterApply() {
        selectedFilter = .red
        takePicture = true
    }
    
    @objc func greenFilterApply() {
        selectedFilter = .green
        takePicture = true
    }
    
    @objc func blueFilterApply() {
        selectedFilter = .blue
        takePicture = true
    }
    
    func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            self.setupInputs()
            
            DispatchQueue.main.async {
                //setup preview layer
                self.setupPreviewLayer()
            }
            
            self.setupOutput()
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs(){
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("no back camera")
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("no front camera")
        }
        
        guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("could not create input device from back camera")
        }
        backInput = bInput
        if !captureSession.canAddInput(backInput) {
            fatalError("could not add back camera input to capture session")
        }
        
        guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("could not create input device from front camera")
        }
        frontInput = fInput
        if !captureSession.canAddInput(frontInput) {
            fatalError("could not add front camera input to capture session")
        }
        
        captureSession.addInput(frontInput)
    }
    
    func setupOutput(){
        videoOutput = AVCaptureVideoDataOutput()
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            fatalError("could not add video output")
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, below: switchCameraButton.layer)
        previewLayer.frame = self.view.layer.frame
    }
    
    func switchCameraInput(){
        switchCameraButton.isUserInteractionEnabled = false
        
        captureSession.beginConfiguration()
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.connections.first?.isVideoMirrored = !backCameraOn
        captureSession.commitConfiguration()
        switchCameraButton.isUserInteractionEnabled = true
    }
    
    //MARK:- Actions
    @objc func captureImage(_ sender: UIButton?){
        selectedFilter = nil
        takePicture = true
    }
    
    @objc func switchCamera(_ sender: UIButton?){
        switchCameraInput()
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !takePicture {
            return
        }
        
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        DispatchQueue.main.async {
            self.takePicture = false
            
            let context = CIContext(options: nil)
            if let currentFilter = CIFilter(name: "CISepiaTone") {
                currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
                currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)

                if let output = currentFilter.outputImage {
                    if let cgimg = context.createCGImage(output, from: output.extent) {
                        let processedImage = UIImage(cgImage: cgimg)
                        
                        if let filterColor = self.selectedFilter {
                            let filteredImage = self.colorized(with: filterColor, imageInput: processedImage)
                            self.capturedImageView.image = filteredImage
                        } else {
                            self.capturedImageView.image = processedImage
                        }
                        
                    }
                }
            }
        }
    }
    
    func colorized(with color: UIColor, imageInput: UIImage) -> UIImage? {
        guard
            let ciimage = CIImage(image: imageInput),
            let colorMatrix = CIFilter(name: "CIColorMatrix")
            else { return nil }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        colorMatrix.setDefaults()
        colorMatrix.setValue(ciimage, forKey: "inputImage")
        colorMatrix.setValue(CIVector(x: r, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrix.setValue(CIVector(x: 0, y: g, z: 0, w: 0), forKey: "inputGVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: b, w: 0), forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: a), forKey: "inputAVector")
        if let ciimage = colorMatrix.outputImage {
            return UIImage(ciImage: ciimage)
        }
        return nil
    }
        
}
