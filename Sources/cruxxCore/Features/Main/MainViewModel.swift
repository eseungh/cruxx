import Foundation
import cruxxModel

/// 메인 화면에서 필요한 데이터를 관리합니다.
public final class MainViewModel: ObservableObject {
    @Published public private(set) var recentSessions: [ClimbingSession] = []
    @Published public private(set) var totalCount: Int = 0

    private let sessionManager: SessionManagerProtocol

    public init(sessionManager: SessionManagerProtocol = SessionManager()) {
        self.sessionManager = sessionManager
    }

    /// 저장된 세션 정보를 불러와 요약합니다.
    public func loadDashboard() {
        let sessions = sessionManager.fetchSessions()
        totalCount = sessions.count
        recentSessions = sessions.sorted(by: { $0.createdAt > $1.createdAt })
            .prefix(3)
            .map { $0 }
    }
}
