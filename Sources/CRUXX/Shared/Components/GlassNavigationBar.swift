import SwiftUI

/// 네비게이션 바에 글래스모피즘 효과를 주는 뷰 모디파이어입니다.
public struct GlassNavigationBar: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
    }
}

public extension View {
    /// 글래스모피즘 네비게이션 바를 적용합니다.
    func glassNavigationBar() -> some View {
        modifier(GlassNavigationBar())
    }
}
