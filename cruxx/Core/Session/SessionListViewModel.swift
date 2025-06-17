import Foundation
import SwiftUI
import CoreData

/// 저장된 세션 목록을 관리하는 뷰모델입니다.
@MainActor
final class SessionListViewModel: ObservableObject {
    @Published private(set) var sessions: [ClimbingSession] = []
    private let context = PersistenceController.shared.viewContext

    init() {
        loadSessions()
    }

    /// Core Data에서 세션 데이터를 불러옵니다.
    func loadSessions() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ClimbingSession")
        do {
            let result = try context.fetch(request)
            sessions = result.compactMap { object in
                guard
                    let id = object.value(forKey: "id") as? UUID,
                    let filename = object.value(forKey: "filename") as? String,
                    let filePath = object.value(forKey: "filePath") as? String,
                    let date = object.value(forKey: "date") as? Date
                else { return nil }
                let duration = object.value(forKey: "duration") as? Double
                return ClimbingSession(id: id, filename: filename, filePath: filePath, date: date, duration: duration)
            }
        } catch {
            print("세션 로드 실패: \(error)")
        }
    }
}

