import Foundation
import cruxxModel

/// 세션 리스트 데이터를 관리하는 뷰모델입니다.
public final class SessionListViewModel: ObservableObject {
    @Published public private(set) var sessions: [ClimbingSession] = []

    private let sessionManager: SessionManagerProtocol

    public init(sessionManager: SessionManagerProtocol = SessionManager()) {
        self.sessionManager = sessionManager
        loadSessions()
    }

    /// 저장된 세션 목록을 다시 불러옵니다.
    public func loadSessions() {
        sessions = sessionManager.fetchSessions()
    }

    /// 세션을 삭제합니다.
    public func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            sessionManager.deleteSession(session)
        }
        loadSessions()
    }
}
