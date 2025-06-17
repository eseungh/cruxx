import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(layer: viewModel.previewLayer)
                .ignoresSafeArea()

            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                Circle()
                    .fill(viewModel.isRecording ? Color.gray : Color.red)
                    .frame(width: 80, height: 80)
            }
            .padding(.bottom, 40)
        }
    }
}

/// AVCaptureVideoPreviewLayer를 SwiftUI에서 사용하기 위한 래퍼입니다.
struct CameraPreviewView: UIViewRepresentable {
    let layer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
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
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        layer.frame = uiView.bounds
    }
}

#Preview {
    RecordingView()
}
