import Foundation
import AVFoundation

/// 녹화 상태와 액션을 관리하는 뷰모델입니다.
@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording: Bool = false
    private let manager = RecordingManager()

    var previewLayer: AVCaptureVideoPreviewLayer {
        manager.previewLayer
    }

    /// 녹화를 시작합니다.
    func startRecording() {
        manager.startSession()
        manager.startRecording()
        isRecording = true
    }

    /// 녹화를 종료합니다.
    func stopRecording() {
        manager.stopRecording { [weak self] in
            self?.isRecording = false
            self?.manager.stopSession()
        }
    }
}
