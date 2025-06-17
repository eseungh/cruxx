import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: viewModel.session)
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
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

#Preview {
    RecordingView()
}
