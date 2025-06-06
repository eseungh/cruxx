import SwiftUI
import AVKit

/// 저장된 세션을 리스트로 보여주는 화면입니다.
public struct SessionListView: View {
    @StateObject private var viewModel = SessionListViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sessions) { session in
                    NavigationLink(destination: VideoPlayer(player: AVPlayer(url: session.fileURL))) {
                        HStack {
                            Text(session.fileName)
                            Spacer()
                            Text(dateFormatter.string(from: session.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteSession)
            }
            .navigationTitle("세션 기록")
            .onAppear { viewModel.loadSessions() }
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }
}
