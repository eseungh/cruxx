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
        print("녹화 토글: 현재 상태 - \(state)")
        switch state {
        case .idle, .stopped:
            startRecording()
        case .recording:
            stopRecording()
        }
    }

    private func startRecording() {
        print("startRecording 호출")
        cameraService.startRecording { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.state = .recording
                    print("녹화 시작됨")
                } else {
                    self.alertMessage = "녹화를 시작할 수 없습니다."
                    self.state = .idle
                    print("녹화 시작 실패")
                }
            }
        }
    }

    private func stopRecording() {
        print("stopRecording 호출")
        cameraService.stopRecording { [weak self] url in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.state = .stopped
                print("녹화 중지 완료")
            }
            guard let url = url else {
                self.alertMessage = "영상 저장에 실패했습니다."
                print("저장 실패")
                return
            }
            print("저장된 파일명: \(url.lastPathComponent)")
            let fileName = url.lastPathComponent
            let session = ClimbingSession(fileName: fileName, fileURL: url)
            self.sessionManager.saveSession(session)
        }
    }
}
