import Foundation
import Combine

/// 녹화 상태를 나타냅니다.
public enum RecordingState {
    case idle
    case recording
    case stopped
}

/// 녹화 화면 상태와 이벤트를 처리하는 뷰모델입니다.
public final class RecordingViewModel: ObservableObject {
    @Published public private(set) var state: RecordingState = .idle
    @Published public var alertMessage: String?

    public let cameraService: CameraServiceProtocol
    private let sessionManager: SessionManagerProtocol

    public init(cameraService: CameraServiceProtocol = CameraService(),
                sessionManager: SessionManagerProtocol = SessionManager()) {
        self.cameraService = cameraService
        self.sessionManager = sessionManager
    }

    /// 녹화 시작 또는 중지를 토글합니다.
    public func toggleRecording() {
        switch state {
        case .idle, .stopped:
            startRecording()
        case .recording:
            stopRecording()
        }
    }

    private func startRecording() {
        cameraService.startRecording { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.state = .recording
                } else {
                    self.alertMessage = "녹화를 시작할 수 없습니다."
                    self.state = .idle
                }
            }
        }
    }

    private func stopRecording() {
        cameraService.stopRecording { [weak self] url in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.state = .stopped
            }
            guard let url = url else {
                self.alertMessage = "영상 저장에 실패했습니다."
                return
            }
            let fileName = url.lastPathComponent
            let session = ClimbingSession(fileName: fileName, fileURL: url)
            self.sessionManager.saveSession(session)
        }
    }
}
