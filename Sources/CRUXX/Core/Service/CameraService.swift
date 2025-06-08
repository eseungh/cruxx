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
    private var currentOutputURL: URL?
    private let sessionQueue = DispatchQueue(label: "CameraService.Session")

    public init(writer: VideoWriterProtocol = VideoWriter()) {
        self.videoWriter = writer
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

    public func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: PhotoCaptureDelegate(completion: completion))
    }

    public func startRecording(completion: @escaping (Bool) -> Void) {
        print("녹화 시작 요청")
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard !self.movieOutput.isRecording else {
                print("이미 녹화 중")
                DispatchQueue.main.async { completion(false) }
                return
            }
            let url = self.videoWriter.startWriting()
            self.currentOutputURL = url
            if let connection = self.movieOutput.connection(with: .video) {
                let deviceOrientation = UIDevice.current.orientation
                if #available(iOS 17.0, *) {
                    let angle = Self.rotationAngle(for: deviceOrientation)
                    if connection.isVideoRotationAngleSupported(angle) {
                        connection.videoRotationAngle = angle
                    }
                    if let previewConnection = self.previewLayer.connection,
                       previewConnection.isVideoRotationAngleSupported(angle) {
                        previewConnection.videoRotationAngle = angle
                    }
                } else {
                    let orientation = Self.videoOrientation(from: deviceOrientation)
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = orientation
                    }
                    self.previewLayer.connection?.videoOrientation = orientation
                }
            }
            self.movieOutput.startRecording(to: url, recordingDelegate: self)
            print("녹화 시작")
            DispatchQueue.main.async { completion(true) }
        }
    }

    public func stopRecording(completion: @escaping (URL?) -> Void) {
        print("녹화 중지 요청")
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

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraService: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        videoWriter.finishWriting { _ in }
        if let error = error {
            print("녹화 중 오류 발생: \(error)")
            DispatchQueue.main.async { [weak self] in self?.recordingCompletion?(nil) }
        } else {
            print("녹화 파일 저장 완료: \(outputFileURL.lastPathComponent)")
            DispatchQueue.main.async { [weak self] in self?.recordingCompletion?(outputFileURL) }
        }
        recordingCompletion = nil
        currentOutputURL = nil
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
