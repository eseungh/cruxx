#if canImport(SwiftUI)
import SwiftUI

/// 앱 전반에서 사용되는 기본 버튼 스타일입니다.
public struct PrimaryButton: View {
    public var title: String
    public var action: () -> Void

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}
#endif

#if DEBUG
struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "버튼") {}
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
