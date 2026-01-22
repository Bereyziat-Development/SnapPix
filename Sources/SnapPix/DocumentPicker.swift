//
//  DocumentPicker.swift
//
//
//  Created by Pavel Kurzo on 22/01/2026.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

@available(iOS 14.0, *)
struct DocumentPicker: UIViewControllerRepresentable {
    var allowedUTTypes: [UTType]
    
    @Binding var selectedFileURL: URL?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(selectedFileURL: $selectedFileURL, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedUTTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
}

@available(iOS 14.0, *)
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    @Binding var selectedFileURL: URL?
    @Binding var isPresented: Bool
    
    init(selectedFileURL: Binding<URL?>, isPresented: Binding<Bool>) {
        self._selectedFileURL = selectedFileURL
        self._isPresented = isPresented
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            self.isPresented = false
            return
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            self.isPresented = false
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let destinationURL = tempDirectory.appendingPathComponent(url.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: url, to: destinationURL)
            self.selectedFileURL = destinationURL
        } catch {
            print("Error copying file: \(error)")
            self.selectedFileURL = nil
        }
        url.stopAccessingSecurityScopedResource()
        
        self.isPresented = false
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.isPresented = false
    }
}
