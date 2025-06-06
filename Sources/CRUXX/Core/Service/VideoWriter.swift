import Foundation
import AVFoundation

/// 영상 저장을 담당하는 서비스 프로토콜입니다.
public protocol VideoWriterProtocol {
    func startWriting() -> URL
    func appendFrame(_ sampleBuffer: CMSampleBuffer)
    func finishWriting(completion: @escaping (URL?) -> Void)
}

/// AVCaptureMovieFileOutput을 활용한 기본 구현체입니다.
public final class VideoWriter: NSObject, VideoWriterProtocol {
    private var outputURL: URL?

    public func startWriting() -> URL {
        let fileName = "session-\(UUID().uuidString).mov"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        outputURL = tempURL
        return tempURL
    }

    public func appendFrame(_ sampleBuffer: CMSampleBuffer) {
        // AVCaptureMovieFileOutput 사용 시 별도 프레임 처리는 필요 없습니다.
    }

    public func finishWriting(completion: @escaping (URL?) -> Void) {
        completion(outputURL)
        outputURL = nil
    }
}
