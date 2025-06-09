import Foundation
import AVKit

/// 세션 상세 화면에서 영상을 재생하고 분석 결과를 제공하는 뷰모델입니다.
public final class SessionDetailViewModel: ObservableObject {
    @Published public private(set) var player: AVPlayer?

    private let session: ClimbingSession

    public init(session: ClimbingSession) {
        self.session = session
        self.player = AVPlayer(url: session.fileURL)
    }
}
