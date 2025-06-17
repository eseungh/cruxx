import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(layer: viewModel.previewLayer)
                .ignoresSafeArea()

            HStack {
                if viewModel.isRecording {
                    Button(action: { viewModel.stopRecording() }) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 70, height: 70)
                    }
                } else {
                    Button(action: { viewModel.startRecording() }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }
}

/// AVCaptureVideoPreviewLayer를 SwiftUI에서 사용하기 위한 래퍼입니다.
struct CameraPreview: UIViewRepresentable {
    let layer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
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
