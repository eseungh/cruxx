import Foundation

/// 세션 정보를 저장하기 위한 DTO 입니다.
public struct SessionDTO: Codable {
    /// 세션 식별자
    public let id: UUID
    /// 영상 파일 이름
    public let fileName: String
    /// 영상 파일 경로
    public let fileURL: URL
    /// 저장 시각
    public let createdAt: Date
}
