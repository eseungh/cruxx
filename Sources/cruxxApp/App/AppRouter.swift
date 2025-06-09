import SwiftUI

/// 탭 기반 메인 네비게이션을 담당합니다.
public struct AppRouter: View {
    public init() {}

    public var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            RecordingView()
                .tabItem {
                    Label("녹화", systemImage: "video.circle")
                }

            SessionListView()
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

#if DEBUG
struct AppRouter_Previews: PreviewProvider {
    static var previews: some View {
        AppRouter()
    }
}
#endif
