import SwiftUI
import AVKit

/// 단일 세션 영상을 재생하고 분석 정보를 표시합니다.
public struct SessionDetailView: View {
    @StateObject private var viewModel: SessionDetailViewModel

    public init(session: ClimbingSession) {
        _viewModel = StateObject(wrappedValue: SessionDetailViewModel(session: session))
    }

    public var body: some View {
        VStack {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onAppear { player.play() }
            }
        }
        .navigationTitle(viewModel.player == nil ? "세션" : "세션 상세")
    }
}

#if DEBUG
struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = ClimbingSession(fileName: "sample.mov", fileURL: URL(fileURLWithPath: "/dev/null"))
        SessionDetailView(session: sample)
    }
}
#endif
