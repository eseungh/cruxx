import Foundation
import AVFoundation
import UIKit
import cruxxCore
import cruxxModel

/// AVFoundation 기반 기본 카메라 서비스 구현체입니다.
public final class CameraService: NSObject, CameraServiceProtocol {
    public private(set) var previewLayer: AVCaptureVideoPreviewLayer

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    private let videoWriter: VideoWriterProtocol
    private let sessionManager: SessionManagerProtocol
    private var currentOutputURL: URL?
    private let sessionQueue = DispatchQueue(label: "CameraService.Session")

    private var isRecording = false
    public init(writer: VideoWriterProtocol = VideoWriter(),
                sessionManager: SessionManagerProtocol = SessionManager()) {
        self.videoWriter = writer
        self.sessionManager = sessionManager
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
    }

    public func startCamera(completion: @escaping (Bool) -> Void) {
        print("카메라 시작 요청")
        checkPermission { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                print("카메라 권한 거부")
                completion(false)
                return
            }
            self.sessionQueue.async {
                self.configureSession()
                self.session.startRunning()
                if let connection = self.previewLayer.connection {
                    if #available(iOS 17.0, *) {
                        if connection.isVideoRotationAngleSupported(0) {
                            connection.videoRotationAngle = 0
                        }
                    } else {
                        if connection.isVideoOrientationSupported {
                            connection.videoOrientation = .portrait
                        }
                    }
                }
                if let vConn = self.videoOutput.connection(with: .video), vConn.isVideoOrientationSupported {
                    vConn.videoOrientation = .portrait
                }
                print("카메라 세션 시작")
                DispatchQueue.main.async { completion(true) }
            }
        }
    }

    public func stopCamera() {
        print("카메라 세션 중지")
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    public func capturePhoto(completion: @escaping (Data?) -> Void) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(completion: completion))
    }

    public func startRecording(completion: @escaping (Bool) -> Void) {
        print("녹화 시작 요청")
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            let url = self.videoWriter.startWriting()
            self.currentOutputURL = url
            self.isRecording = true
            print("녹화 시작")
            DispatchQueue.main.async { completion(true) }
        }
    }

    public func stopRecording(completion: @escaping (URL?) -> Void) {
        print("녹화 중지 요청")
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.isRecording = false
            self.videoWriter.finishWriting { [weak self] url in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    completion(url)
                }
                if let url = url {
                    let session = ClimbingSession(fileName: url.lastPathComponent, fileURL: url)
                    self.sessionManager.saveSession(session)
                }
                self.currentOutputURL = nil
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

        if session.canAddOutput(videoOutput) {
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(videoOutput)
        }

        if session.canAddOutput(audioOutput) {
            audioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(audioOutput)
        }

        print("카메라 세션 구성 완료")
    }

    func checkPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("카메라 권한 허용")
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("카메라 권한 획득")
                } else {
                    print("카메라 권한 거부됨")
                }
                completion(granted)
            }
        default:
            print("카메라 사용 불가 상태")
            completion(false)
        }
    }

    @available(iOS, introduced: 13.0, deprecated: 17.0)
    static func videoOrientation(from orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .portrait
        }
    }

    static func rotationAngle(for orientation: UIDeviceOrientation) -> Double {
        switch orientation {
        case .portrait: return 0
        case .landscapeRight: return 90
        case .portraitUpsideDown: return 180
        case .landscapeLeft: return 270
        default: return 0
        }
    }
}

// MARK: - 샘플 버퍼 처리 델리게이트
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording else { return }
        videoWriter.appendFrame(sampleBuffer)
    }
}

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Data?) -> Void

    init(completion: @escaping (Data?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 캡처 오류: \(error)")
            completion(nil)
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            completion(nil)
            return
        }
        completion(data)
    }
}
