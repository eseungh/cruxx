import Foundation

/// 등반 세션 모델을 나타냅니다.
public struct ClimbingSession: Identifiable, Codable {
    /// 세션 고유 식별자
    public let id: UUID
    /// 저장된 영상 파일 이름
    public let fileName: String
    /// 영상 파일이 저장된 경로
    public let fileURL: URL
    /// 세션 기록 시각
    public let createdAt: Date

    public init(id: UUID = UUID(), fileName: String, fileURL: URL, createdAt: Date = Date()) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.createdAt = createdAt
    }
}

public extension ClimbingSession {
    /// DTO 로부터 모델을 생성합니다.
    init(dto: SessionDTO) {
        self.init(id: dto.id, fileName: dto.fileName, fileURL: dto.fileURL, createdAt: dto.createdAt)
    }

    /// 모델을 DTO 로 변환합니다.
    func toDTO() -> SessionDTO {
        SessionDTO(id: id, fileName: fileName, fileURL: fileURL, createdAt: createdAt)
    }
}
