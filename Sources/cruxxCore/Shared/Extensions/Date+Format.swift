import Foundation

public extension Date {
    /// 세션 목록 등에서 사용되는 공통 포맷터입니다.
    static var sessionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
