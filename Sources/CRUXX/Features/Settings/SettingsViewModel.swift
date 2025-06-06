import Foundation

/// 사용자 설정을 저장하고 불러오는 뷰모델입니다.
public final class SettingsViewModel: ObservableObject {
    @Published public var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Self.nKey) }
    }
    @Published public var darkModeEnabled: Bool {
        didSet { UserDefaults.standard.set(darkModeEnabled, forKey: Self.dKey) }
    }

    private static let nKey = "notificationsEnabled"
    private static let dKey = "darkModeEnabled"

    public init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Self.nKey)
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: Self.dKey)
    }
}
