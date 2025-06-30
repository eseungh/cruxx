import Foundation
import SwiftUI
import CoreData

/// 저장된 세션 목록을 관리하는 뷰모델입니다.
@MainActor
final class SessionListViewModel: ObservableObject {
    @Published private(set) var sessions: [ClimbingSessionModel] = []
    private let context = PersistenceController.shared.viewContext
    private var saveObserver: NSObjectProtocol?
    private var deleteObserver: NSObjectProtocol?

    init() {
        loadSessions()
        saveObserver = NotificationCenter.default.addObserver(
            forName: .didSaveClimbingSession,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
                Task { @MainActor in
                    self.loadSessions()
            }
        }

        deleteObserver = NotificationCenter.default.addObserver(
            forName: .didDeleteAllSessions,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.loadSessions()
            }
        }
    }

    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
        }
        if let deleteObserver {
            NotificationCenter.default.removeObserver(deleteObserver)
        }
    }

    /// Core Data에서 세션 데이터를 불러옵니다.
    func loadSessions() {
        let request = NSFetchRequest<ClimbingSession>(entityName: "ClimbingSession")
        do {
            let result = try context.fetch(request)
            sessions = result.map { ClimbingSessionModel(from: $0) }
        } catch {
            print("세션 로드 실패: \(error)")
        }
    }

    /// 선택한 비디오 파일을 앱의 세션으로 등록합니다.
    func importVideo(from url: URL) {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let rawDir = documents.appendingPathComponent("raw", isDirectory: true)
        try? fileManager.createDirectory(at: rawDir, withIntermediateDirectories: true)
        let targetURL = rawDir.appendingPathComponent("session_\(UUID().uuidString).mov")
        do {
            try fileManager.copyItem(at: url, to: targetURL)
        } catch {
            print("비디오 복사 실패: \(error)")
        }

        let session = ClimbingSessionModel(
            id: UUID(),
            filename: targetURL.lastPathComponent,
            filePath: targetURL.path,
            date: Date(),
            duration: nil
        )
        insertSession(session)

        if UserDefaults.standard.bool(forKey: "autoAnalyze") {
            runAutoAnalyze(url: targetURL)
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

    /// 비디오 분석을 자동으로 실행합니다.
    private func runAutoAnalyze(url: URL) {
        // TODO: PoseAnalyzer 연동 예정
        print("자동 분석 시작: \(url.lastPathComponent)")
    }
}

