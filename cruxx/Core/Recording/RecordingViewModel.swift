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
    @Published var countdown: Int?

    private let includeMic: Bool
    private let countdownSeconds: Int
    private let autoAnalyzeAfterRecording: Bool

    private let recordingManager: RecordingManager
    private var elapsedTimer: Timer?
    private var countdownTimer: Timer?
    private var backgroundObserver: NSObjectProtocol?
    private let context = PersistenceController.shared.viewContext

    init(includeMic: Bool, countdownSeconds: Int, autoAnalyze: Bool) {
        self.includeMic = includeMic
        self.countdownSeconds = countdownSeconds
        self.autoAnalyzeAfterRecording = autoAnalyze
        self.recordingManager = RecordingManager(includeMic: includeMic)

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
        countdownTimer?.invalidate()
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

    /// 녹화를 시작합니다. 카운트다운이 설정된 경우 카운트다운 후 시작합니다.
    func startRecording() {
        if countdownSeconds > 0 {
            countdown = countdownSeconds
            countdownTimer?.invalidate()
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self else { return }
                Task { @MainActor in
                    guard let remaining = self.countdown else { return }
                    if remaining > 1 {
                        self.countdown = remaining - 1
                    } else {
                        timer.invalidate()
                        self.countdown = nil
                        self.startActualRecording()
                    }
                }
            }
        } else {
            startActualRecording()
        }
    }

    /// 실제 녹화 로직을 수행합니다.
    private func startActualRecording() {
        recordingManager.startRecording()
        isRecording = true
        startElapsedTimer()
    }

    /// 녹화를 종료합니다.
    func stopRecording() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        recordingManager.stopRecording { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.isRecording = false
                self.stopElapsedTimer()
                if let path {
                    let url = URL(fileURLWithPath: path)
                    let session = ClimbingSessionModel(
                        id: UUID(),
                        filename: url.lastPathComponent,
                        filePath: path,
                        date: Date(),
                        duration: self.elapsedTime
                    )
                    self.insertSession(session)
                    print("Saved session: \(session)")
                    if self.autoAnalyzeAfterRecording {
                        self.runAutoAnalyze(url: url)
                    }
                }
                self.showSaveMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                Task { @MainActor in
                    self?.showSaveMessage = false
                }
            }

            if self.autoAnalyzeAfterRecording {
                print("Auto analyze session")
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
            NotificationCenter.default.post(name: .didSaveClimbingSession, object: nil)
        } catch {
            print("세션 저장 실패: \(error)")
        }
    }

    /// 녹화 파일에 대해 자동 분석을 실행합니다. 실제 분석 로직은 추후 구현됩니다.
    private func runAutoAnalyze(url: URL) {
        // TODO: PoseAnalyzer 연동 예정
        print("자동 분석 시작: \(url.lastPathComponent)")
    }
}
