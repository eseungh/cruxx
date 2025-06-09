import XCTest
@testable import cruxxCore

final class SessionManagerTests: XCTestCase {
    /// 세션을 저장하고 불러올 수 있는지 확인합니다.
    func testSaveAndFetchSession() {
        let repo = MockSessionRepository()
        let manager = SessionManager(repository: repo)
        let session = ClimbingSession(fileName: "test.mov", fileURL: URL(fileURLWithPath: "test.mov"))
        manager.saveSession(session)
        let fetched = manager.fetchSessions()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, session.id)
    }
}
