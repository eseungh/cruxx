import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecordingViewModel()
    @State private var countdown: Int?
    @State private var countdownTimer: Timer?
    @State private var blink = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()

            if let remaining = countdown {
                Text("\(remaining)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            VStack {
                if viewModel.isRecording {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .opacity(blink ? 0.2 : 1)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: blink)
                            .onAppear { blink.toggle() }

                        Text("REC \(timeString(from: viewModel.elapsedTime))")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
                }

                Spacer()

                if viewModel.showSaveMessage {
                    Text("Recording saved!")
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .padding(.bottom, 80)
                }

                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else if countdown == nil {
                        startCountdown()
                    }
                }) {
                    Circle()
                        .fill(viewModel.isRecording ? Color.gray : Color.red)
                        .frame(width: 80, height: 80)
                }
                .disabled(countdown != nil)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(.top, 60)
            .padding(.leading, 16)
        }
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }

    private func startCountdown() {
        countdown = 3
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let current = countdown else { return }
            if current > 1 {
                countdown = current - 1
            } else {
                timer.invalidate()
                countdown = nil
                Task { @MainActor in
                    viewModel.startRecording()
                }
            }
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingView()
}
