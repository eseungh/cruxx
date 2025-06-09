// SettingsViewModel 테스트

import XCTest
@testable import cruxxCore

final class SettingsViewModelTests: XCTestCase {
    func test알림설정변경시저장됨() {
        // 변경 후 값이 UserDefaults에 반영되는지 확인합니다.
        let vm = SettingsViewModel()
        vm.notificationsEnabled = true
        let stored = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        XCTAssertTrue(stored)
    }
}
