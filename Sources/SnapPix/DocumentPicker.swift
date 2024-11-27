//
//  DocumentPicker.swift
//  SnapPix
//
//  Created by Pavel Kurzo on 15/11/2024.
//

import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var isShowingFileSizeError: Bool
    var sizeLimit: Int

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .image, .pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let documentPicker: DocumentPicker

        init(_ documentPicker: DocumentPicker) {
            self.documentPicker = documentPicker
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let fileURL = urls.first else {
                print("No file selected")

                return }
            print("Selected file URL: \(fileURL.path)")

            
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                print("File attributes: \(attributes)")

                if let fileSize = attributes[.size] as? Int, fileSize <= documentPicker.sizeLimit {
                    print(fileSize)
                    print("File size is within limit")


                    documentPicker.fileURL = fileURL
                    documentPicker.isShowingFileSizeError = false
                } else {
                    print("File size exceeds limit")

                    documentPicker.fileURL = nil
                    documentPicker.isShowingFileSizeError = true
                }
            } catch {
                print("Error while getting file attributes: \(error)")
            }
        }
    }
}
