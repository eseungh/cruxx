import Foundation
import AVFoundation


/// AVFoundation을 이용해 카메라 세션과 녹화를 관리합니다.
final class RecordingManager: NSObject {
    @AppStorage("includeMic") private var includeMic: Bool = true
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "RecordingSessionQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    private let portraitDimensions = (width: 1080, height: 1920)

    private var writer: AVAssetWriter?
    private var writerInput: AVAssetWriterInput?
    private var writerAudioInput: AVAssetWriterInput?
    private var startTime: CMTime?
    private var outputURL: URL?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter
    }()
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        if let connection = layer.connection {
            if #available(iOS 17.0, *) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            } else if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        return layer
    }
    
    override init() {
        super.init()
        configureSession()
    }
    
    /// 카메라 세션을 설정합니다.
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        if includeMic {
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        }
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(videoOutput)
        }

        if includeMic {
            if session.canAddOutput(audioOutput) {
                audioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
                session.addOutput(audioOutput)
            }
        }
        
        if let connection = videoOutput.connection(with: .video) {
            if #available(iOS 17.0, *) {
                if connection.isVideoRotationAngleSupported(90) {
                    connection.videoRotationAngle = 90
                }
            } else if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
        }
        
        session.commitConfiguration()
    }
    
    /// 카메라 세션을 시작합니다.
    func startSession() {
        // 마이크 권한을 요청합니다.
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    /// 카메라 세션을 종료합니다.
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    /// 녹화를 시작합니다.
    func startRecording() {
        sessionQueue.async {
            if let writer = self.writer,
               writer.status == .failed || writer.status == .completed {
                self.writer = nil
                self.writerInput = nil
                self.writerAudioInput = nil
                self.startTime = nil
            }

            self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            self.audioOutput.setSampleBufferDelegate(nil, queue: nil)
            if self.includeMic {
                self.audioOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            }
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let rawDir = documents.appendingPathComponent("raw", isDirectory: true)
            try? FileManager.default.createDirectory(at: rawDir, withIntermediateDirectories: true)
            let timestamp = Self.dateFormatter.string(from: Date())
            let url = rawDir.appendingPathComponent("session_\(timestamp).mov")
            try? FileManager.default.removeItem(at: url)
            self.outputURL = url
            
            let assetWriter: AVAssetWriter
            do {
                assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
            } catch {
                print("AssetWriter 초기화 실패: \(error.localizedDescription)")
                return
            }
            
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: self.portraitDimensions.width,
                AVVideoHeightKey: self.portraitDimensions.height
            ]
            
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: 0)

            if assetWriter.canAdd(input) {
                assetWriter.add(input)
                self.writerInput = input
            }

            if self.includeMic {
                let audioSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 44100,
                    AVEncoderBitRateKey: 64000
                ]
                let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
                audioInput.expectsMediaDataInRealTime = true
                if assetWriter.canAdd(audioInput) {
                    assetWriter.add(audioInput)
                    self.writerAudioInput = audioInput
                }
            }
            
            self.startTime = nil
            self.writer = assetWriter
            assetWriter.startWriting()
        }
    }
    
    /// 녹화를 종료하고 파일을 저장합니다.
    func stopRecording(completion: @escaping (String?) -> Void) {
        sessionQueue.async {
            guard let writer = self.writer, let input = self.writerInput else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            input.markAsFinished()
            self.writerAudioInput?.markAsFinished()
            self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
            self.audioOutput.setSampleBufferDelegate(nil, queue: nil)
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
            
            writer.finishWriting { [weak self] in
                guard let self else { return }
                let url = writer.outputURL
                self.writer = nil
                self.writerInput = nil
                self.writerAudioInput = nil
                self.startTime = nil
                // 녹화 정리 후 프리뷰 재시작
                self.startSession()
                DispatchQueue.main.async {
                    completion(url.path)
                }
            }
        }
    }

}

extension RecordingManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output is AVCaptureAudioDataOutput {
            guard includeMic else { return }
            guard let writer = writer,
                  writer.status == .writing,
                  let input = writerAudioInput,
                  input.isReadyForMoreMediaData else { return }

            if startTime == nil {
                startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                writer.startSession(atSourceTime: startTime!)
            }
            input.append(sampleBuffer)
            return
        }

        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        } else if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        guard let writer = writer,
              writer.status == .writing,
              let input = writerInput,
              input.isReadyForMoreMediaData else { return }

        if startTime == nil {
            startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            writer.startSession(atSourceTime: startTime!)
        }

        input.append(sampleBuffer)
    }
}
