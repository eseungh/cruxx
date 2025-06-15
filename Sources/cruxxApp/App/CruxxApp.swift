#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import cruxxCore

/// 앱의 시작점을 정의합니다.
@main
struct CruxxApp: App {
    /// 세로 모드 고정을 위해 AppDelegate를 연결합니다.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container: DIContainer

    init() {
        // SessionManager는 @MainActor에서 생성 후 DIContainer에 주입합니다.
        let manager = SessionManager()
        _container = StateObject(wrappedValue: DIContainer(sessionManager: manager))
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(container)
        }
    }
}

#if DEBUG
struct CruxxApp_Previews: PreviewProvider {
    static var previews: some View {
        AppRouter()
            .environmentObject(DIContainer(sessionManager: SessionManager()))
    }
}
#endif
#endif
