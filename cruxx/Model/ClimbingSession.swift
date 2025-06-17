import Foundation

/// 등반 세션 정보를 나타내는 모델입니다.
struct ClimbingSession: Identifiable {
    let id: UUID
    let filename: String
    let filePath: String
    let date: Date
    let duration: Double?
}
