import SwiftUI
import cruxxCore
import cruxxModel

/// 최근 세션 요약과 간단한 통계를 보여주는 메인 화면입니다.
public struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("총 세션 수: \(viewModel.totalCount)")
                        .font(.headline)
                    Spacer()
                }

                if viewModel.recentSessions.isEmpty {
                    Text("최근 세션이 없습니다.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.recentSessions) { session in
                        VStack(alignment: .leading) {
                            Text(session.fileName)
                            Text(Date.sessionDateFormatter.string(from: session.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(height: 150)
                }

                HStack(spacing: 16) {
                    PrimaryButton(title: "새 녹화") {
                        // 녹화 탭으로 이동하는 간단한 안내
                        // 실제 탭 전환은 상위 뷰에서 처리
                    }
                    PrimaryButton(title: "전체 분석") {
                        // 추후 고급 분석 기능
                    }
                }
            }
            .padding()
            .navigationTitle("대시보드")
            .onAppear { viewModel.loadDashboard() }
        }
        .glassNavigationBar()
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
