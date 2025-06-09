import Foundation

/// 앱 전역에서 사용되는 서비스 인스턴스를 보관합니다.
public final class DIContainer: ObservableObject {
    public let sessionManager: SessionManagerProtocol
    public let cameraService: CameraServiceProtocol

    public init(sessionManager: SessionManagerProtocol = SessionManager(),
                cameraService: CameraServiceProtocol? = nil) {
        self.sessionManager = sessionManager
        self.cameraService = cameraService ?? CameraService(sessionManager: sessionManager)
    }
}
