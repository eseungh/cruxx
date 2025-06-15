#if canImport(UIKit)
import Foundation
import cruxxCore

/// 앱 전역에서 사용되는 서비스 인스턴스를 보관합니다.
public final class DIContainer: ObservableObject {
    public let sessionManager: SessionManagerProtocol
    public let cameraService: CameraServiceProtocol

    /// SessionManager는 외부에서 생성하여 주입합니다.
    /// 예시:
    /// ```swift
    /// Task { @MainActor in
    ///     let manager = SessionManager()
    ///     let container = DIContainer(sessionManager: manager)
    /// }
    /// ```
    public init(sessionManager: SessionManagerProtocol,
                cameraService: CameraServiceProtocol? = nil) {
        self.sessionManager = sessionManager
        self.cameraService = cameraService ?? CameraService(sessionManager: sessionManager)
    }
}
#endif
