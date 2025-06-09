import Foundation
@testable import cruxx
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AVFoundation)
import AVFoundation
#endif

// 메모리 기반 세션 저장소 목 객체
final class MockSessionRepository: SessionRepositoryProtocol {
    var sessions: [ClimbingSession] = []

    func getSessions() -> [ClimbingSession] { sessions }
    func addSession(_ session: ClimbingSession) { sessions.append(session) }
    func removeSession(_ session: ClimbingSession) { sessions.removeAll { $0.id == session.id } }
    func updateSession(_ session: ClimbingSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) { sessions[index] = session }
    }
}

// 세션 매니저 목 객체
final class MockSessionManager: SessionManagerProtocol {
    var repository: MockSessionRepository = .init()

    func fetchSessions() -> [ClimbingSession] { repository.getSessions() }
    func saveSession(_ session: ClimbingSession) { repository.addSession(session) }
    func deleteSession(_ session: ClimbingSession) { repository.removeSession(session) }
    func updateSession(_ session: ClimbingSession) { repository.updateSession(session) }
    func fetchSession(by id: UUID) -> ClimbingSession? { repository.getSessions().first { $0.id == id } }
}

#if canImport(AVFoundation) && canImport(UIKit)
// 실제 하드웨어 접근을 하지 않는 카메라 서비스 목 객체
final class MockCameraService: CameraServiceProtocol {
    var previewLayer: AVCaptureVideoPreviewLayer = .init()
    var didStartRecording = false
    var didStopRecording = false
    var recordingURL: URL? = FileManager.default.temporaryDirectory.appendingPathComponent("test.mov")

    func startCamera(completion: @escaping (Bool) -> Void) { completion(true) }
    func stopCamera() {}
    func capturePhoto(completion: @escaping (UIImage?) -> Void) { completion(nil) }
    func startRecording(completion: @escaping (Bool) -> Void) {
        didStartRecording = true
        completion(true)
    }
    func stopRecording(completion: @escaping (URL?) -> Void) {
        didStopRecording = true
        completion(recordingURL)
    }
}
#endif
