import Foundation
import AVFoundation
import Photos

/// AVFoundation을 이용해 카메라 세션과 녹화를 관리합니다.
final class RecordingManager: NSObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "RecordingSessionQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private let portraitDimensions = (width: 1080, height: 1920)

    private var writer: AVAssetWriter?
    private var writerInput: AVAssetWriterInput?
    private var startTime: CMTime?

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

        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(videoOutput)
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
                self.startTime = nil
            }

            self.videoOutput.setSampleBufferDelegate(nil, queue: nil)
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("cruxx_temp.mov")
            try? FileManager.default.removeItem(at: url)

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
            input.transform = CGAffineTransform(rotationAngle: .pi / 2)

            if assetWriter.canAdd(input) {
                assetWriter.add(input)
                self.writerInput = input
            }

            self.startTime = nil
            self.writer = assetWriter
            assetWriter.startWriting()
        }
    }

    /// 녹화를 종료하고 파일을 저장합니다.
    func stopRecording(completion: @escaping () -> Void) {
        sessionQueue.async {
            guard let writer = self.writer, let input = self.writerInput else {
                DispatchQueue.main.async { completion() }
                return
            }

            input.markAsFinished()

            if self.session.isRunning {
                self.session.stopRunning()
            }

            writer.finishWriting { [weak self] in
                guard let self else { return }
                let url = writer.outputURL
                self.writer = nil
                self.writerInput = nil
                self.startTime = nil
                DispatchQueue.main.async {
                    self.saveVideo(at: url)
                    completion()
                }
            }
        }
    }

    /// 완성된 영상을 포토 라이브러리에 저장합니다.
    private func saveVideo(at url: URL) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if let error = error {
                    print("영상 저장 오류: \(error.localizedDescription)")
                }
                DispatchQueue.global(qos: .background).async {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
    }
}

extension RecordingManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        } else if connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        guard let writer = writer, writer.status == .writing, let input = writerInput, input.isReadyForMoreMediaData else {
            return
        }

        if startTime == nil {
            startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            writer.startSession(atSourceTime: startTime!)
        }

        input.append(sampleBuffer)
    }
}
