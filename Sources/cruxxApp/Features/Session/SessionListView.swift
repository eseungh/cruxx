import SwiftUI
import AVKit
import cruxxCore
import cruxxModel

/// 저장된 세션을 리스트로 보여주는 화면입니다.
public struct SessionListView: View {
    @StateObject private var viewModel = SessionListViewModel()

    public init() {}

    public var body: some View {
        NavigationView {
            List {
                if viewModel.sessions.isEmpty {
                    Text("세션 없음")
                        .foregroundColor(.secondary)
                }
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

#if DEBUG
struct SessionListView_Previews: PreviewProvider {
    static var previews: some View {
        SessionListView()
    }
}
#endif
