//
//  SnapPix.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI
import UniformTypeIdentifiers

@available(iOS 13.0, *)
/// A SwiftUI view that allows users to select images from their device or camera.

public struct SnapPix<
    ImagePreview: View,
    AddImageLabel: View,
    DeleteImageLabel: View
>: View {
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var isShowingDocumentPicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @State private var selectedFileURL: URL?
    @ViewBuilder private var imagePreview: (Image) -> ImagePreview
    @ViewBuilder private var addImageLabel: () -> AddImageLabel
    @ViewBuilder private var deleteImageLabel: () -> DeleteImageLabel
    private var addImageCallback: (() -> Void)?
    private var deleteImageCallback: (() -> Void)?
    private var fileSelectedCallback: ((URL) -> Void)?
    
    // Features related variables
    @Binding private var uiImages: [UIImage]
    private var allowDeletion: Bool = false
    private var maxImageCount: Int = 5
    private var supportedFileExtensions: [String]
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    
    // Design related variables
    private var gridMin: CGFloat = 100
    private var spacing: CGFloat = 10
    
    private var canAddImage: Bool { uiImages.count < maxImageCount }
    
    /// Initializes a SnapPix view.
    /// - Parameters:
    ///   - uiImages: A binding to an array of UIImages.
    ///   - maxImageCount: The maximum number of images allowed (default is 5).
    ///   - gridMin: The minimum width for the grid columns (default is 100).
    ///   - spacing: The spacing between images in the grid (default is 16)
    ///   - allowDeletion: Whether to allow deletion of images (default is false).
    ///   - supportedFileExtensions: Optional array of supported file extensions. If nil, uses default formats: jpg, jpeg, png, pdf, xls, xlsx, gdoc, gsheet, doc, docx, ppt, pptx, txt.
    ///   - addImageCallback: Callback called when an image is added.
    ///   - deleteImageCallback: Callback called when an image is deleted.
    ///   - fileSelectedCallback: Callback called when a non-image file is selected. Receives the file URL.
    ///   - imagePreview: View builder for image preview.
    ///   - addImageLabel: View builder for add image label.
    ///   - deleteImageLabel: View builder for delete image label.
    ///
    public init(
        uiImages: Binding<[UIImage]>,
        maxImageCount: Int = 5,
        gridMin: CGFloat = 100,
        spacing: CGFloat = 16,
        allowDeletion: Bool = false,
        supportedFileExtensions: [String]? = nil,
        addImageCallback: (() -> Void)? = nil,
        deleteImageCallback: (() -> Void)? = nil,
        fileSelectedCallback: ((URL) -> Void)? = nil,
        @ViewBuilder imagePreview: @escaping (Image) -> ImagePreview = {
            image in SPImagePreview(image: image)
        },
        @ViewBuilder addImageLabel: @escaping () -> AddImageLabel = { SPAddImageLabel() },
        @ViewBuilder deleteImageLabel: @escaping () -> DeleteImageLabel = { SPDeleteImageLabel() }
    ) {
        self._uiImages = uiImages
        self.maxImageCount = maxImageCount
        self.gridMin = gridMin
        self.spacing = spacing
        self.allowDeletion = allowDeletion
        self.supportedFileExtensions = supportedFileExtensions ?? defaultSupportedFileExtensions
        self.imagePreview = imagePreview
        self.deleteImageLabel = deleteImageLabel
        self.addImageLabel = addImageLabel
        self.addImageCallback = addImageCallback
        self.deleteImageCallback = deleteImageCallback
        self.fileSelectedCallback = fileSelectedCallback
    }
    
    public var body: some View {
        VStack {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: gridMin))],
                spacing: spacing
            ) {
                ForEach(Array(uiImages.enumerated()), id: \.offset) { index, uiImage in
                    imagePreview(Image(uiImage: uiImage))
                        .overlay {
                            DeleteImageButton(index)
                        }
                }
                if canAddImage {
                    Button {
#if os(visionOS)
                        if #available(iOS 14.0, *) {
                            isShowingDocumentPicker = true
                        } else {
                            isShowingImagePicker = true
                            sourceType = .photoLibrary
                        }
#endif
#if os(iOS)
                        isShowingImageSourceTypeActionSheet = true
#endif
                    } label: {
                        addImageLabel()
                    }
                }
            }
        }
        .sheet(
            isPresented: $isShowingImagePicker,
            onDismiss: addImageIfSelected
        ) {
            ImagePicker(
                sourceType: sourceType ?? .photoLibrary,
                uiImage: $selectedImage,
                isPresented: $isShowingImagePicker
            )
        }
        .sheet(
            isPresented: $isShowingDocumentPicker,
            onDismiss: handleFileSelection
        ) {
            if #available(iOS 14.0, *) {
                DocumentPicker(
                    allowedUTTypes: FileTypeHelper.utTypes(from: supportedFileExtensions),
                    selectedFileURL: $selectedFileURL,
                    isPresented: $isShowingDocumentPicker
                )
            }
        }
        
#if os(iOS)
        .actionSheet(isPresented: $isShowingImageSourceTypeActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Choose file"),
                message: Text("Please choose a file or picture"),
                buttons: [
                    ActionSheet.Button.default(
                        Text("Photo library"),
                        action: {
                            isShowingImagePicker = true
                            sourceType = .photoLibrary
                        }
                    ),
                    ActionSheet.Button.default(
                        Text("Camera"),
                        action: {
                            isShowingImagePicker = true
                            sourceType = .camera
                        }
                    ),
                    ActionSheet.Button.default(
                        Text("Files"),
                        action: {
                            if #available(iOS 14.0, *) {
                                isShowingDocumentPicker = true
                            }
                        }
                    ),
                    ActionSheet.Button.cancel()
                ]
            )
        }
#endif
    }
    
    private func addImageIfSelected() {
        guard let selectedImage else { return }
        uiImages.append(selectedImage)
        self.selectedImage = nil
        addImageCallback?()
    }
    
    private func handleFileSelection() {
        guard let fileURL = selectedFileURL else { return }
        
        if #available(iOS 14.0, *) {
            let pathExtension = fileURL.pathExtension.lowercased()
            
            if ["jpg", "jpeg", "png"].contains(pathExtension) {
                if let imageData = try? Data(contentsOf: fileURL),
                   let image = UIImage(data: imageData) {
                    uiImages.append(image)
                    addImageCallback?()
                }
            } else {
                fileSelectedCallback?(fileURL)
            }
        }
        
        self.selectedFileURL = nil
    }
    
    @ViewBuilder
    private func DeleteImageButton(_ index: Int) -> some View {
        VStack {
            HStack {
                Spacer()
                if allowDeletion {
                    Button {
                        uiImages.remove(at: index)
                        deleteImageCallback?()
                    } label: {
                        deleteImageLabel()
                    }
                }
            }
            Spacer()
        }
        .offset(x: 3, y: -6)
    }
}

public struct SPImagePreview: View {
    var image: Image
    
    public init(image: Image) {
        self.image = image
    }
    
    public var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

public struct SPAddImageLabel: View {
    public init() {}
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: 100, height: 100)
            .shadow(color: .gray.opacity(0.4), radius: 8, x: 4, y: 4)
            .overlay(
                Image(systemName: "camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.black.opacity(0.6))
            )
    }
}

public struct SPDeleteImageLabel: View {
    public init() {}
    
    public var body: some View {
        Image(systemName: "xmark")
            .foregroundColor(.white)
            .padding(8)
            .background(Circle().fill(Color.black.opacity(0.3)))
            .frame(width: 20, height: 20)
    }
}

struct ExampleView: View {
    @State private var uiImages = [UIImage]()
    
    public var body: some View {
        SnapPix(
            uiImages: $uiImages,
            allowDeletion: true,
            addImageCallback: { print("Nice! Image sent 🚀")}
        )
    }
}

#Preview("Default implementation") {
    ExampleView()
    
}
