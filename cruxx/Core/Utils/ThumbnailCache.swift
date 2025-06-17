import UIKit

/// 메모리 기반 썸네일 캐시를 관리하는 싱글턴 클래스입니다.
final class ThumbnailCache {
    static let shared = ThumbnailCache()
    private init() {}

    private var cache: [String: UIImage] = [:]

    /// 지정한 키에 해당하는 이미지를 반환합니다.
    func get(for key: String) -> UIImage? {
        return cache[key]
    }

    /// 이미지를 캐시에 저장합니다.
    func set(_ image: UIImage, for key: String) {
        cache[key] = image
    }
}
