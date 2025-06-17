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
    @State private var thumbnail: UIImage?

    init(session: ClimbingSessionModel) {
        self.session = session
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
        .onAppear {
            let key = session.id.uuidString
            if let cached = ThumbnailCache.shared.get(for: key) {
                thumbnail = cached
            } else {
                let url = URL(fileURLWithPath: session.filePath)
                generateThumbnailAsync(from: url) { image in
                    if let image {
                        ThumbnailCache.shared.set(image, for: key)
                        thumbnail = image
                    }
                }
            }
        }
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

/// 비동기적으로 썸네일을 생성합니다.
private func generateThumbnailAsync(from url: URL, completion: @escaping (UIImage?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let image = generateThumbnail(from: url)
        DispatchQueue.main.async {
            completion(image)
        }
    }
}

#Preview {
    SessionListView()
}

