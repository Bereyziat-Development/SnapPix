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
    var sizeLimit: Int = 2 * 1024 * 1024
    
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
        @Binding var isShowingFileSizeError: Bool
        
        init(_ documentPicker: DocumentPicker) {
            self.documentPicker = documentPicker
            _isShowingFileSizeError = documentPicker._isShowingFileSizeError
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let fileURL = urls.first else { return }
            
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? Int, fileSize <= documentPicker.sizeLimit {
                    documentPicker.fileURL = fileURL
                    isShowingFileSizeError = false
                } else {
                    print("file too large")
                    documentPicker.fileURL = nil
                    isShowingFileSizeError = true
                }
            } catch {
                print("error while getting attrributes")
            }
        }
    }
}
