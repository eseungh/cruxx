import Foundation
import SwiftUI

/// 저장된 세션 목록을 관리하는 뷰모델입니다.
@MainActor
final class SessionListViewModel: ObservableObject {
    /// 등반 세션 데이터 구조입니다.
    struct ClimbingSession: Identifiable {
        let id = UUID()
        let filename: String
        let date: Date
        let fileURL: URL
    }

    @Published private(set) var sessions: [ClimbingSession] = []

    init() {
        loadMockSessions()
    }

    /// 임시 목업 세션 데이터를 생성합니다.
    private func loadMockSessions() {
        let baseURL = FileManager.default.temporaryDirectory
        sessions = (1...10).map { index in
            let filename = "session_\(index).mov"
            return ClimbingSession(
                filename: filename,
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                fileURL: baseURL.appendingPathComponent(filename)
            )
        }
    }
}

