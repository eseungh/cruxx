import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        ZStack {
            CameraPreviewView(layer: viewModel.previewLayer)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 16) {
                    Text(viewModel.isRecording ? "Recording..." : "Ready")
                        .font(.headline)
                        .foregroundColor(.white)

                    Button(action: {
                        if viewModel.isRecording {
                            viewModel.stopRecording()
                        } else {
                            viewModel.startRecording()
                        }
                    }) {
                        Circle()
                            .fill(viewModel.isRecording ? Color.gray : Color.red)
                            .frame(width: 70, height: 70)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.bottom, 32)
            }
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
