import Foundation
import AVFoundation


/// 영상 저장을 담당하는 서비스 프로토콜입니다.

public protocol VideoWriterProtocol {
    func startWriting() -> URL
    func appendFrame(_ sampleBuffer: CMSampleBuffer)
    func finishWriting(completion: @escaping (URL?) -> Void)
}


/// AVAssetWriter를 사용해 영상을 저장하는 기본 구현체입니다.
public final class VideoWriter: NSObject, VideoWriterProtocol {
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var outputURL: URL?

    /// 기록을 시작하고 저장될 임시 파일 경로를 반환합니다.
    public func startWriting() -> URL {
        let fileName = "session-\(UUID().uuidString).mov"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        outputURL = url
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
            setupInputs()
            assetWriter?.startWriting()
        } catch {
            print("AssetWriter 초기화 실패: \(error)")
        }
        return url
    }

    /// 카메라에서 전달받은 샘플 버퍼를 기록합니다.
    public func appendFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let writer = assetWriter, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        let isVideo = sampleBuffer.formatDescription?.mediaType == kCMMediaType_Video
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        if writer.status == .unknown {
            writer.startSession(atSourceTime: timestamp)
        }
        if isVideo {
            if let input = videoInput, input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        } else {
            if let input = audioInput, input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
    }

    /// 기록을 종료하고 저장된 파일 URL을 전달합니다.
    public func finishWriting(completion: @escaping (URL?) -> Void) {
        guard let writer = assetWriter else {
            completion(nil)
            return
        }
        videoInput?.markAsFinished()
        audioInput?.markAsFinished()
        writer.finishWriting { [weak self] in
            guard let self = self else { return }
            completion(self.outputURL)
            self.cleanup()
        }
    }

    /// 입력 설정을 구성합니다.
    private func setupInputs() {
        guard let writer = assetWriter else { return }
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1080,
            AVVideoHeightKey: 1920
        ]
        let vInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        vInput.expectsMediaDataInRealTime = true
        vInput.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        if writer.canAdd(vInput) { writer.add(vInput) }
        videoInput = vInput

        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 64000
        ]
        let aInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        aInput.expectsMediaDataInRealTime = true
        if writer.canAdd(aInput) { writer.add(aInput) }
        audioInput = aInput
    }

    private func cleanup() {
        assetWriter = nil
        videoInput = nil
        audioInput = nil
        outputURL = nil
    }
}
