import Foundation
import SwiftUI
import CoreData

/// 저장된 세션 목록을 관리하는 뷰모델입니다.
@MainActor
final class SessionListViewModel: ObservableObject {
    @Published private(set) var sessions: [ClimbingSessionModel] = []
    private let context = PersistenceController.shared.viewContext
    private var saveObserver: NSObjectProtocol?

    init() {
        loadSessions()
        saveObserver = NotificationCenter.default.addObserver(
            forName: .didSaveClimbingSession,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadSessions()
        }
    }

    deinit {
        if let saveObserver {
            NotificationCenter.default.removeObserver(saveObserver)
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
}

