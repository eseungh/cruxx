import SwiftUI
import AVFoundation

/// 라이브 카메라 프리뷰와 녹화 버튼을 제공하는 화면입니다.
struct RecordingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecordingViewModel()
    @AppStorage("countdownSeconds") private var countdownSeconds: Int = 3
    @AppStorage("autoAnalyze") private var autoAnalyze: Bool = false
    @State private var countdown: Int?
    @State private var countdownTimer: Timer?
    @State private var blink = false

    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()

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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
                }

                Spacer()

                if viewModel.showSaveMessage {
                    Text("Recording saved!")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
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
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                }
                .disabled(countdown != nil)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

            if let remaining = countdown {
                Text("\(remaining)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
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
                    .background(
                        .ultraThinMaterial,
                        in: Circle()
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
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
        guard countdownSeconds > 0 else {
            viewModel.autoAnalyzeAfterRecording = autoAnalyze
            viewModel.startRecording()
            return
        }
        countdown = countdownSeconds
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let current = countdown else { return }
            if current > 1 {
                countdown = current - 1
            } else {
                timer.invalidate()
                countdown = nil
                Task { @MainActor in
                    viewModel.autoAnalyzeAfterRecording = autoAnalyze
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
