import XCTest
@testable import cruxx

final class MainViewModelTests: XCTestCase {
    /// 최근 세션이 3개까지 정렬되어 로드되는지 확인합니다.
    func test대시보드로드시최근3개세션정렬() {
        let repo = MockSessionRepository()
        let manager = SessionManager(repository: repo)
        let now = Date()
        repo.sessions = [
            ClimbingSession(fileName: "a.mov", fileURL: URL(fileURLWithPath: "a.mov"), createdAt: now.addingTimeInterval(-60)),
            ClimbingSession(fileName: "b.mov", fileURL: URL(fileURLWithPath: "b.mov"), createdAt: now),
            ClimbingSession(fileName: "c.mov", fileURL: URL(fileURLWithPath: "c.mov"), createdAt: now.addingTimeInterval(-30)),
            ClimbingSession(fileName: "d.mov", fileURL: URL(fileURLWithPath: "d.mov"), createdAt: now.addingTimeInterval(-90))
        ]
        let vm = MainViewModel(sessionManager: manager)
        vm.loadDashboard()
        XCTAssertEqual(vm.totalCount, 4)
        XCTAssertEqual(vm.recentSessions.map { $0.fileName }, ["b.mov", "c.mov", "a.mov"])
    }
}
