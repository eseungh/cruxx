import SwiftUI
import AVKit

/// 선택한 등반 세션의 영상을 재생하며 정보를 보여주는 화면입니다.
struct SessionDetailView: View {
    let session: ClimbingSessionModel
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .topTrailing) {
                if let player {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                        .background(Color.black)
                } else {
                    Color.black
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                }

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            .ultraThinMaterial,
                            in: Rectangle()
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                }
                .padding()
            }
            .clipShape(Rectangle())
            .padding(.top)

            VStack(alignment: .leading, spacing: 6) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .ultraThinMaterial,
                in: Rectangle()
            )
            .overlay(
                Rectangle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal)

            Spacer()
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
