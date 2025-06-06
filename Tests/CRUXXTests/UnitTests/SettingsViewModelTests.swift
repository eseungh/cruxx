import XCTest
@testable import CRUXX

final class SettingsViewModelTests: XCTestCase {
    func testTogglePersistence() {
        let vm = SettingsViewModel()
        vm.notificationsEnabled = true
        let stored = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        XCTAssertTrue(stored)
    }
}
