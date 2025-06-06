import Foundation
import AVFoundation
import UIKit

/// 카메라 및 녹화를 제어하는 서비스 프로토콜입니다.
public protocol CameraServiceProtocol {
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    func startCamera(completion: @escaping (Bool) -> Void)
    func stopCamera()
    func capturePhoto(completion: @escaping (UIImage?) -> Void)
    func startRecording(completion: @escaping (Bool) -> Void)
    func stopRecording(completion: @escaping (URL?) -> Void)
}

/// AVFoundation 기반 기본 카메라 서비스 구현체입니다.
public final class CameraService: NSObject, CameraServiceProtocol {
    public private(set) var previewLayer: AVCaptureVideoPreviewLayer

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoWriter: VideoWriterProtocol
    private var recordingCompletion: ((URL?) -> Void)?
    private let sessionQueue = DispatchQueue(label: "CameraService.Session")

    public init(writer: VideoWriterProtocol = VideoWriter()) {
        self.videoWriter = writer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
    }

    public func startCamera(completion: @escaping (Bool) -> Void) {
        checkPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else { completion(false); return }
            self.sessionQueue.async {
                self.configureSession()
                self.session.startRunning()
                DispatchQueue.main.async { completion(true) }
            }
        }
    }

    public func stopCamera() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    public func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(completion: completion))
    }

    public func startRecording(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard !self.movieOutput.isRecording else { DispatchQueue.main.async { completion(false) }; return }
            let url = self.videoWriter.startWriting()
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
            DispatchQueue.main.async { completion(true) }
        }
    }

    public func stopRecording(completion: @escaping (URL?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.recordingCompletion = completion
            if self.movieOutput.isRecording {
                self.movieOutput.stopRecording()
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}

private extension CameraService {
    func configureSession() {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .high

        // 입력 설정
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else { return }
        session.addInput(videoInput)

        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        // 출력 설정
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
    }

    func checkPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraService: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("녹화 중 오류 발생: \(error)")
            DispatchQueue.main.async { [weak self] in self?.recordingCompletion?(nil) }
        } else {
            videoWriter.finishWriting { _ in }
            DispatchQueue.main.async { [weak self] in self?.recordingCompletion?(outputFileURL) }
        }
        recordingCompletion = nil
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 캡처 오류: \(error)")
            completion(nil)
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            completion(nil)
            return
        }
        completion(image)
    }
}
