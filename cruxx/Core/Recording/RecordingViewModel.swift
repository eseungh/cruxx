import Foundation
import AVFoundation
import UIKit
import CoreData

/// 녹화 상태와 액션을 관리하는 뷰모델입니다.
@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var showSaveMessage: Bool = false
    private let recordingManager = RecordingManager()
    private var elapsedTimer: Timer?
    private var backgroundObserver: NSObjectProtocol?
    private let context = PersistenceController.shared.viewContext

    init() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.isRecording {
                    self.stopRecording()
                }
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
        recordingManager.stopRecording { [weak self] identifier in
            guard let self else { return }
            Task { @MainActor in
                self.isRecording = false
                self.stopElapsedTimer()
                if let id = identifier {
                    let session = ClimbingSessionModel(
                        id: UUID(),
                        filename: "\(id).mov",
                        filePath: id,
                        date: Date(),
                        duration: self.elapsedTime
                    )
                    self.insertSession(session)
                    print("Saved session: \(session)")
                }
                self.showSaveMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                Task { @MainActor in
                    self?.showSaveMessage = false
                }
            }
        }
    }

    /// Core Data에 세션을 저장합니다.
    private func insertSession(_ session: ClimbingSessionModel) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "ClimbingSession", into: context)
        entity.setValue(session.id, forKey: "id")
        entity.setValue(session.filename, forKey: "filename")
        entity.setValue(session.filePath, forKey: "filePath")
        entity.setValue(session.date, forKey: "date")
        entity.setValue(session.duration, forKey: "duration")
        do {
            try context.save()
        } catch {
            print("세션 저장 실패: \(error)")
        }
    }
}
