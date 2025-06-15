#if canImport(XCTest)
import XCTest
@testable import cruxxCore

final class SessionListViewModelTests: XCTestCase {
    /// 삭제 기능 동작 시 세션이 제거되는지 확인합니다.
    func testDeleteUpdatesSessionList() {
        let repo = MockSessionRepository()
        let manager = SessionManager(repository: repo)
        let session = ClimbingSession(fileName: "a.mov", fileURL: URL(fileURLWithPath: "a.mov"))
        repo.sessions = [session]
        let vm = SessionListViewModel(sessionManager: manager)
        vm.deleteSession(at: IndexSet(integer: 0))
        XCTAssertTrue(manager.fetchSessions().isEmpty)
        XCTAssertTrue(vm.sessions.isEmpty)
    }
}
#endif
