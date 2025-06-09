import Foundation
import cruxxModel

/// 세션 저장소 프로토콜입니다.
public protocol SessionRepositoryProtocol {
    func getSessions() -> [ClimbingSession]
    func addSession(_ session: ClimbingSession)
    func removeSession(_ session: ClimbingSession)
    func updateSession(_ session: ClimbingSession)
}

/// 로컬 파일을 사용한 기본 세션 저장소 구현체입니다.
public final class SessionRepository: SessionRepositoryProtocol {
    private let fileURL: URL
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documents.appendingPathComponent("sessions.json")
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil)
        }
    }

    public func getSessions() -> [ClimbingSession] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let dtos = (try? JSONDecoder().decode([SessionDTO].self, from: data)) ?? []
        return dtos.map { ClimbingSession(dto: $0) }
    }

    public func addSession(_ session: ClimbingSession) {
        var sessions = getSessions()
        sessions.append(session)
        saveSessions(sessions)
    }

    public func removeSession(_ session: ClimbingSession) {
        var sessions = getSessions()
        sessions.removeAll { $0.id == session.id }
        saveSessions(sessions)
        try? fileManager.removeItem(at: session.fileURL)
    }

    public func updateSession(_ session: ClimbingSession) {
        var sessions = getSessions()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions(sessions)
        }
    }

    private func saveSessions(_ sessions: [ClimbingSession]) {
        let dtos = sessions.map { $0.toDTO() }
        guard let data = try? JSONEncoder().encode(dtos) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
