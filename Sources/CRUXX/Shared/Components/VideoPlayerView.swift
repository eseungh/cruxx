import SwiftUI
import AVKit

/// 지정된 URL 의 영상을 재생하는 뷰입니다.
public struct VideoPlayerView: View {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
    }
}

#if DEBUG
struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        // 프리뷰용 더미 URL
        VideoPlayerView(url: URL(fileURLWithPath: "/dev/null"))
    }
}
#endif
