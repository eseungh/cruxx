import SwiftUI
import CoreData

/// 앱 설정 화면을 제공합니다.
struct SettingsView: View {
    @AppStorage("includeMic") private var includeMic: Bool = true
    @AppStorage("countdownSeconds") private var countdownSeconds: Int = 3
    @AppStorage("autoAnalyze") private var autoAnalyze: Bool = false

    @State private var sessionCount: Int = 0
    @State private var showDeleteAlert = false

    private let context = PersistenceController.shared.viewContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                storageSection
                recordingSection
                infoSection
            }
            .padding()
        }
        .navigationTitle("Settings")
        .onAppear { loadSessionCount() }
        .alert("모든 세션을 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) { deleteAllSessions() }
            Button("취소", role: .cancel) {}
        }
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Sessions: \(sessionCount)")
            Text("Total Storage: 123 MB")
            Button("Delete All Sessions") { showDeleteAlert = true }
            Button("Clear Thumbnail Cache") { ThumbnailCache.shared.clear() }
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(16)
        .background(.ultraThinMaterial, in: Rectangle())
        .overlay(Rectangle().stroke(Color.white.opacity(0.15)))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private var recordingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Include Microphone Audio", isOn: $includeMic)
            Picker("Countdown Duration", selection: $countdownSeconds) {
                Text("0초").tag(0)
                Text("3초").tag(3)
                Text("5초").tag(5)
            }
            .pickerStyle(.segmented)
            Toggle("Auto Analyze After Recording", isOn: $autoAnalyze)
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(16)
        .background(.ultraThinMaterial, in: Rectangle())
        .overlay(Rectangle().stroke(Color.white.opacity(0.15)))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private var infoSection: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"

        return VStack(alignment: .leading, spacing: 16) {
            Text("Version: \(version) (\(build))")
            Button("Send Feedback") {
                // TODO: 메일 링크로 연결 예정
            }
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(16)
        .background(.ultraThinMaterial, in: Rectangle())
        .overlay(Rectangle().stroke(Color.white.opacity(0.15)))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func loadSessionCount() {
        let request = NSFetchRequest<ClimbingSession>(entityName: "ClimbingSession")
        if let result = try? context.count(for: request) {
            sessionCount = result
        }
    }

    private func deleteAllSessions() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClimbingSession")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        try? context.save()
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let rawDir = documents.appendingPathComponent("raw", isDirectory: true)
        if let files = try? FileManager.default.contentsOfDirectory(at: rawDir, includingPropertiesForKeys: nil) {
            for url in files { try? FileManager.default.removeItem(at: url) }
        }
        loadSessionCount()
        NotificationCenter.default.post(name: .didDeleteAllSessions, object: nil)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
