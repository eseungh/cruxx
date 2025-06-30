import SwiftUI
import PhotosUI

/// PHPickerViewController를 래핑하여 비디오 선택을 처리합니다.
struct VideoPickerView: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.hasItemConformingToTypeIdentifier("public.movie") else { return }

            provider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, _ in
                guard let srcURL = url else { return }

                let fileManager = FileManager.default
                let targetURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                try? fileManager.copyItem(at: srcURL, to: targetURL)

                DispatchQueue.main.async {
                    self.onPick(targetURL)
                }
            }
        }
    }
}
