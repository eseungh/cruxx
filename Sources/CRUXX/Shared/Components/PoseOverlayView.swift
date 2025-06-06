import SwiftUI

/// 스켈레톤 포인트를 화면에 표시하는 간단한 오버레이 뷰입니다.
public struct PoseOverlayView: View {
    /// 0~1 사이로 정규화된 포인트 배열
    public var points: [CGPoint]

    public init(points: [CGPoint]) {
        self.points = points
    }

    public var body: some View {
        GeometryReader { geometry in
            ForEach(points.indices, id: \.self) { index in
                let point = points[index]
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
                    .position(x: point.x * geometry.size.width,
                              y: (1 - point.y) * geometry.size.height)
            }
        }
    }
}

#if DEBUG
struct PoseOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        PoseOverlayView(points: [CGPoint(x: 0.5, y: 0.5)])
            .background(Color.black)
    }
}
#endif
