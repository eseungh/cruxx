// SettingsViewModel 테스트

import XCTest
@testable import cruxxCore

final class SettingsViewModelTests: XCTestCase {
    /// 알림 설정 변경 시 값이 저장되는지 확인합니다.
    func testNotificationSettingPersistence() {
        // 변경 후 값이 UserDefaults에 반영되는지 확인합니다.
        let vm = SettingsViewModel()
        vm.notificationsEnabled = true
        let stored = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        XCTAssertTrue(stored)
    }
}
