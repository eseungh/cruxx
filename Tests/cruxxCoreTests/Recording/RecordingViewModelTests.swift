import XCTest
@testable import cruxxCore

final class RecordingViewModelTests: XCTestCase {
    /// 녹화 시작 시 상태가 변경되고 서비스가 호출되는지 확인합니다.
    @MainActor
    func testStartRecordingChangesState() async throws {
        let camera = MockCameraService()
        let manager = MockSessionManager()
        let vm = RecordingViewModel(cameraService: camera, sessionManager: manager)
        vm.toggleRecording()
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.state, .recording)
        XCTAssertTrue(camera.didStartRecording)
    }
}
