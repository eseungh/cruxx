import Foundation
import AVFoundation

/// 카메라 및 녹화를 제어하는 서비스 프로토콜입니다.
public protocol CameraServiceProtocol {
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    func startCamera(completion: @escaping (Bool) -> Void)
    func stopCamera()
    func capturePhoto(completion: @escaping (Data?) -> Void)
    func startRecording(completion: @escaping (Bool) -> Void)
    func stopRecording(completion: @Sendable @escaping (URL?) -> Void)
}
