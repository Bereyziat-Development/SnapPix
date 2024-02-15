//
//  ImagePicker.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI
import UIKit

/// A SwiftUI representation of an image picker.
@available(iOS 15.0, *)
struct ImagePicker: UIViewControllerRepresentable {
    /// The source type for the image picker.
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    /// Binding to the selected UIImage.
    @Binding var uiImage: UIImage?
    
    /// Binding to determine if the image picker is presented.
    @Binding var isPresented: Bool
    
    /// Creates a coordinator to manage the image picker.
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(uiImage: $uiImage, isPresented: $isPresented)
    }
    
    /// Creates the UIImagePickerController.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        return pickerController
    }

    /// Updates the UIImagePickerController.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
}

/// A coordinator to manage the UIImagePickerController.
@available(iOS 15.0, *)
class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    /// Binding to the selected UIImage.
    @Binding var uiImage: UIImage?
    
    /// Binding to determine if the image picker is presented.
    @Binding var isPresented: Bool
    
    /// Initializes the coordinator.
    init(uiImage: Binding<UIImage?>, isPresented: Binding<Bool>) {
        self._uiImage = uiImage
        self._isPresented = isPresented
    }
    
    /// Called when an image is picked.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.uiImage = pickedImage
        }
        self.isPresented = false
    }
    
    /// Called when image picking is canceled.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
}

/// A preview for the ImagePicker.
@available(iOS 15.0, *)
#Preview {
    ImagePicker(uiImage: .constant(UIImage(named: "Apple")), isPresented: .constant(true))
}
