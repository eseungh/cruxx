import Foundation

/// 등반 세션 정보를 나타내는 모델입니다.
struct ClimbingSessionModel: Identifiable {
    let id: UUID
    let filename: String
    let filePath: String
    let date: Date
    let duration: Double?
}

extension ClimbingSessionModel {
    /// Core Data `ClimbingSession` 엔티티에서 값을 추출해 초기화합니다.
    init(from entity: ClimbingSession) {
        self.id = entity.id ?? UUID()
        self.filename = entity.filename ?? ""
        self.filePath = entity.filePath ?? ""
        self.date = entity.date ?? Date()
        self.duration = entity.duration
    }
}
