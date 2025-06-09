#if canImport(UIKit)
import UIKit

/// iOS 환경에서 전체 화면 방향을 세로로 고정하는 AppDelegate입니다.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
#endif
