import SwiftUI
import Foundation
import AVFoundation
import UIKit

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
    let session: ClimbingSessionModel
    private let thumbnail: UIImage?

    init(session: ClimbingSessionModel) {
        self.session = session
        let url = URL(fileURLWithPath: session.filePath)
        self.thumbnail = generateThumbnail(from: url)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    Text("Preview unavailable")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(height: 180)
            }
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

/// 주어진 비디오 파일 URL에서 첫 프레임을 추출해 썸네일 이미지를 생성합니다.
private func generateThumbnail(from url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: 0, preferredTimescale: 600)
    do {
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        print("썸네일 생성 실패: \(error)")
        return nil
    }
}

#Preview {
    SessionListView()
}

