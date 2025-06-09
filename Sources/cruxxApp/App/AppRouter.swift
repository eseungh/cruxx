#if canImport(SwiftUI)
import SwiftUI

/// 탭 기반 메인 네비게이션을 담당합니다.
public struct AppRouter: View {
    @EnvironmentObject private var container: DIContainer

    public init() {}

    public var body: some View {
        TabView {
            MainView(container: container)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            RecordingView(container: container)
                .tabItem {
                    Label("녹화", systemImage: "video.circle")
                }

            SessionListView(container: container)
                .tabItem {
                    Label("세션", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape")
                }
        }
    }
}
#endif
#if canImport(SwiftUI)
#if DEBUG
struct AppRouter_Previews: PreviewProvider {
    static var previews: some View {
        AppRouter()
            .environmentObject(DIContainer())
    }
}
#endif
#endif
