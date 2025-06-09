import SwiftUI
import AVFoundation

/// 카메라 프리뷰를 보여주는 뷰입니다.
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewContainerView {
        PreviewContainerView(previewLayer: previewLayer)
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.updateFrame()
    }

    /// 프리뷰 레이어의 프레임을 항상 뷰 크기에 맞춰 조정하는 컨테이너입니다.
    final class PreviewContainerView: UIView {
        private let previewLayer: AVCaptureVideoPreviewLayer

        init(previewLayer: AVCaptureVideoPreviewLayer) {
            self.previewLayer = previewLayer
            super.init(frame: .zero)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
            layer.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updateFrame()
        }

        func updateFrame() {
            previewLayer.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.width)
        }
    }
}

/// 영상 녹화 및 프리뷰 화면입니다.
public struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            // 프리뷰 레이어를 화면 전체에 표시합니다.
            CameraPreviewView(previewLayer: viewModel.cameraService.previewLayer)
                .ignoresSafeArea()

            VStack {
                Spacer()
                VStack(spacing: 16) {
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
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.cameraService.startCamera { success in
                if !success {
                    viewModel.alertMessage = "카메라 권한이 필요합니다. 설정에서 권한을 확인하세요."
                }
            }
        }
        .onDisappear {
            viewModel.cameraService.stopCamera()
        }
        .alert(isPresented: .constant(viewModel.alertMessage != nil), content: {
            Alert(title: Text("오류"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("확인")) {
                viewModel.alertMessage = nil
            })
        })
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

#if DEBUG
struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView()
    }
}
#endif
