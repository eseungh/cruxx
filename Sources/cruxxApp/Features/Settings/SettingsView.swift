#if canImport(SwiftUI)
import SwiftUI
import cruxxCore

/// 앱 기본 설정을 보여주는 화면입니다.
public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일반")) {
                    Toggle("알림 허용", isOn: $viewModel.notificationsEnabled)
                    Toggle("다크 모드", isOn: $viewModel.darkModeEnabled)
                }

                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    }
                }
            }
            .navigationTitle("설정")
        }
    }
}
#endif

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
