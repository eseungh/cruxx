import Foundation
import cruxxModel

/// 세션 매니저 프로토콜입니다.
public protocol SessionManagerProtocol {
    func fetchSessions() -> [ClimbingSession]
    func saveSession(_ session: ClimbingSession)
    func deleteSession(_ session: ClimbingSession)
    func updateSession(_ session: ClimbingSession)
    func fetchSession(by id: UUID) -> ClimbingSession?
}

/// 세션 저장과 로딩을 담당하는 매니저 구현체입니다.
public final class SessionManager: SessionManagerProtocol {
    private let repository: SessionRepositoryProtocol

    public init(repository: SessionRepositoryProtocol = SessionRepository()) {
        self.repository = repository
    }

    public func fetchSessions() -> [ClimbingSession] {
        repository.getSessions()
    }

    public func saveSession(_ session: ClimbingSession) {
        repository.addSession(session)
    }

    public func deleteSession(_ session: ClimbingSession) {
        repository.removeSession(session)
    }

    public func updateSession(_ session: ClimbingSession) {
        repository.updateSession(session)
    }

    public func fetchSession(by id: UUID) -> ClimbingSession? {
        repository.getSessions().first(where: { $0.id == id })
    }
}
