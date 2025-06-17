import SwiftUI
import AVKit

/// 선택한 등반 세션의 영상을 재생하며 정보를 보여주는 화면입니다.
struct SessionDetailView: View {
    let session: ClimbingSessionModel
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.filename)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(dateString(from: session.date))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    if let duration = session.duration {
                        Text(timeString(from: duration))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(16)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .padding()
            }

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding()
            }
        }
        .onAppear {
            let url = URL(fileURLWithPath: session.filePath)
            player = AVPlayer(url: url)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let sample = ClimbingSessionModel(
        id: UUID(),
        filename: "Sample.mov",
        filePath: "/path/to/sample.mov",
        date: Date(),
        duration: 65
    )
    return SessionDetailView(session: sample)
}
