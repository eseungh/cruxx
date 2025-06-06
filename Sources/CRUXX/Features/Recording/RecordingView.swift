import SwiftUI
import AVFoundation

/// 카메라 프리뷰를 보여주는 뷰입니다.
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}

/// 영상 녹화 및 프리뷰 화면입니다.
public struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            CameraPreviewView(previewLayer: viewModel.cameraService.previewLayer)
                .frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color.black)

            Text(stateText)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(8)

            Button(action: {
                viewModel.toggleRecording()
            }) {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            viewModel.cameraService.startCamera { success in
                if !success {
                    print("카메라 권한이 필요합니다.")
                }
            }
        }
        .onDisappear {
            viewModel.cameraService.stopCamera()
        }
    }

    private var buttonTitle: String {
        viewModel.state == .recording ? "녹화 중지" : "녹화 시작"
    }

    private var stateText: String {
        switch viewModel.state {
        case .idle: return "대기 중"
        case .recording: return "녹화 중"
        case .stopped: return "녹화 완료"
        }
    }
}
