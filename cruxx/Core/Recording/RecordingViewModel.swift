import Foundation
import AVFoundation

/// 녹화 상태와 액션을 관리하는 뷰모델입니다.
@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording: Bool = false
    private let recordingManager = RecordingManager()

    var session: AVCaptureSession {
        recordingManager.session
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        recordingManager.previewLayer
    }

    /// 카메라 세션을 시작합니다.
    func startSession() {
        recordingManager.startSession()
    }

    /// 카메라 세션을 종료합니다.
    func stopSession() {
        recordingManager.stopSession()
    }

    /// 녹화를 시작합니다.
    func startRecording() {
        recordingManager.startRecording()
        isRecording = true
    }

    /// 녹화를 종료합니다.
    func stopRecording() {
        recordingManager.stopRecording { [weak self] in
            self?.isRecording = false
        }
    }
}
