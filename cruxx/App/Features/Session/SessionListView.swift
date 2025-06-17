import SwiftUI
import Foundation

/// 저장된 세션 영상을 카드 형태로 나열하는 화면입니다.
struct SessionListView: View {
    @StateObject private var viewModel = SessionListViewModel()
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if viewModel.sessions.isEmpty {
                Text("No sessions saved yet.")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.sessions) { session in
                        SessionCard(session: session)
                    }
                }
                .padding()
            }
        }
    }
}

private struct SessionCard: View {
    let session: ClimbingSession
    private let randomHeight: CGFloat = .random(in: 180...260)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: randomHeight)
                .overlay(
                    Image(systemName: "video")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                )
            Text(session.filename)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            Text(dateString(from: session.date))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    SessionListView()
}

