import Foundation
import AVFoundation
import UIKit

/// 녹화 상태와 액션을 관리하는 뷰모델입니다.
@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var showSaveMessage: Bool = false
    private let recordingManager = RecordingManager()
    private var elapsedTimer: Timer?
    private var backgroundObserver: NSObjectProtocol?

    struct ClimbingSession {
        let filename: String
        let date: Date
        let fileURL: URL
    }

    init() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if self.isRecording {
                self.stopRecording()
            }
        }
    }

    deinit {
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func startElapsedTimer() {
        elapsedTime = 0
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.elapsedTime += 1
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

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
        startElapsedTimer()
    }

    /// 녹화를 종료합니다.
    func stopRecording() {
        recordingManager.stopRecording { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.isRecording = false
                self.stopElapsedTimer()
                let url = FileManager.default.temporaryDirectory.appendingPathComponent("cruxx_temp.mov")
                let session = ClimbingSession(filename: url.lastPathComponent, date: Date(), fileURL: url)
                print("Saved session: \(session)")
                self.showSaveMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                Task { @MainActor in
                    self?.showSaveMessage = false
                }
            }
        }
    }
}
