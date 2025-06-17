import SwiftUI
import AVFoundation

/// AVCaptureSession을 이용해 카메라 프리뷰를 보여주는 뷰입니다.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    class VideoPreviewContainer: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }

        func configure(session: AVCaptureSession) {
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
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.layer.addSublayer(layer)
            self.previewLayer = layer
            layer.frame = bounds
        }
    }

    func makeUIView(context: Context) -> VideoPreviewContainer {
        let view = VideoPreviewContainer()
        view.configure(session: session)
        return view
    }

    func updateUIView(_ uiView: VideoPreviewContainer, context: Context) {
        uiView.configure(session: session)
    }
}
