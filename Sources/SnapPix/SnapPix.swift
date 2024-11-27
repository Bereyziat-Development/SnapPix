//
//  SnapPix.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI

@available(iOS 13.0, *)
/// A SwiftUI view that allows users to select images and/or files from their device.
public struct SnapPix<
    ImagePreview: View,
    AddItemLabel: View,
    DeleteItemLabel: View,
    FilePreview: View
>: View {
    // States for UI behavior
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var isShowingFilePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @State private var selectedFileURL: URL?
    @State private var showPermissionAlert = false
    @State private var isShowingFileSizeAlert = false

    // ViewBuilder closures
    @ViewBuilder private var imagePreview: (Image) -> ImagePreview
    @ViewBuilder private var filePreview: (URL) -> FilePreview
    @ViewBuilder private var addItemLabel: (UploadMode) -> AddItemLabel
    @ViewBuilder private var deleteItemLabel: () -> DeleteItemLabel
    
    // Callbacks
    private var addItemCallback: (() -> Void)?
    private var deleteItemCallback: (() -> Void)?

    // Bindings and configuration variables
    @Binding private var uiImages: [UIImage]
    @Binding private var files: [URL]
    var uploadMode: UploadMode = .both
    var maxFileSizeB = 2000 * 1024
    private var allowDeletion: Bool = false
    private var maxImageCount: Int = 5
    
    // Design related variables
    private var gridMin: CGFloat = 100
    private var spacing: CGFloat = 10
    
    private var canAddItem: Bool {
        uiImages.count + files.count < maxImageCount
    }
    /// Initializes a SnapPix view.
    /// - Parameters:
    ///   - uiImages: A binding to an array of `UIImage` (default: empty).
    ///   - files: A binding to an array of file `URL`s (optional, default: nil).
    ///   - uploadMode: The mode of upload (pictures, documents, or both). Default is `.both`.
    ///   - maxImageCount: The maximum number of items allowed (default is 5).
    ///   - gridMin: The minimum width for grid columns (default is 100).
    ///   - spacing: The spacing between grid items (default is 16).
    ///   - allowDeletion: Whether deletion is enabled (default is false).
    ///   - addItemCallback: A callback when an item is added (optional).
    ///   - deleteItemCallback: A callback when an item is deleted (optional).
    ///   - imagePreview: A closure to customize the image preview view.
    ///   - filePreview: A closure to customize the file preview view.
    ///   - addItemLabel: A closure to customize the "add item" label.
    ///   - deleteItemLabel: A closure to customize the delete item label.
    public init(
        uiImages: Binding<[UIImage]> = .constant([]),
        files: Binding<[URL]>? = nil,
        uploadMode: UploadMode = .both,
        maxImageCount: Int = 5,
        maxFileSizeB: Int = 2,
        gridMin: CGFloat = 100,
        spacing: CGFloat = 16,
        allowDeletion: Bool = false,
        addItemCallback: (() -> Void)? = nil,
        deleteItemCallback: (() -> Void)? = nil,
        @ViewBuilder imagePreview: @escaping (Image) -> ImagePreview = { image in
            SPImagePreview(image: image)
        },
        @ViewBuilder filePreview: @escaping (URL) -> FilePreview = { fileURL in
            SPFilePreview(fileURL: fileURL)
        },
        @ViewBuilder addItemLabel: @escaping (UploadMode) -> AddItemLabel = { uploadMode in  SPAddItemLabel(uploadMode: uploadMode) },
        @ViewBuilder deleteItemLabel: @escaping () -> DeleteItemLabel = { SPDeleteItemLabel() }
    ) {
        self._uiImages = uiImages
        self._files = files ?? .constant([])
        self.uploadMode = uploadMode
        self.maxImageCount = maxImageCount
        self.maxFileSizeB = maxFileSizeB
        self.gridMin = gridMin
        self.spacing = spacing
        self.allowDeletion = allowDeletion
        self.imagePreview = imagePreview
        self.filePreview = filePreview
        self.addItemLabel = addItemLabel
        self.deleteItemLabel = deleteItemLabel
        self.addItemCallback = addItemCallback
        self.deleteItemCallback = deleteItemCallback
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: gridMin))],
                spacing: spacing
            ) {
                // Render images if uploadMode includes pictures
                if uploadMode != .documents {
                    ForEach(Array(uiImages.enumerated()), id: \.offset) { index, uiImage in
                        imagePreview(Image(uiImage: uiImage))
                            .overlay {
                                DeleteButton(index)
                            }
                    }
                }

                // Render files if uploadMode includes documents
                if uploadMode != .pictures {
                    ForEach(Array(files.enumerated()), id: \.offset) { index, fileURL in
                        filePreview(fileURL)
                            .overlay {
                                DeleteButton(index, isImage: false)
                            }
                    }
                }

                // Add item button
                if canAddItem {
                    Button {
                        isShowingImageSourceTypeActionSheet = true
                        isShowingFileSizeAlert = false
                    } label: {
                        addItemLabel(uploadMode)
                    }
                }
            }
                if isShowingFileSizeAlert {
                    Text("The selected file is bigger than \(maxFileSizeB / 1024000)MB.")
                               .font(.system(size: 16, weight: .regular))
                               .foregroundColor(.red)
                               .padding(.horizontal)
                               .animation(.easeInOut)
                       }
            
        }
        .sheet(
            isPresented: $isShowingImagePicker,
            onDismiss: addImageIfSelected
        ) {
            ImagePicker(
                sourceType: sourceType!,
                uiImage: $selectedImage,
                isPresented: $isShowingImagePicker
            )
        }
        .sheet(
            isPresented: $isShowingFilePicker,
            onDismiss: {
                DispatchQueue.main.async {
                    addFileIfSelected()
                }
            }
        ) {
            DocumentPicker(fileURL: $selectedFileURL, isShowingFileSizeError: $isShowingFileSizeAlert, sizeLimit: maxFileSizeB)
        }
        .actionSheet(isPresented: $isShowingImageSourceTypeActionSheet) {
            switch uploadMode {
            case .pictures:
                return ActionSheet(
                    title: Text("Choose pictures"),
                    message: Text("Please choose pictures from your gallery"),
                    buttons: [
                        .default(Text("Photo library")) {
                            isShowingImagePicker = true
                            sourceType = .photoLibrary
                        },
                        .default(Text("Camera")) {
                            isShowingImagePicker = true
                            sourceType = .camera
                        },
                        .cancel()
                    ]
                )
            case .documents:
                return ActionSheet(
                    title: Text("Choose files"),
                    message: Text("Please choose files from your file manager"),
                    buttons: [
                        .default(Text("Files")) {
                            isShowingFilePicker = true
                        },
                        .cancel()
                    ]
                )
            case .both:
                return ActionSheet(
                    title: Text("Choose pictures or files"),
                    message: Text("Please choose pictures or files from your gallery"),
                    buttons: [
                        .default(Text("Photo library")) {
                            isShowingImagePicker = true
                            sourceType = .photoLibrary
                        },
                        .default(Text("Camera")) {
                            isShowingImagePicker = true
                            sourceType = .camera
                        },
                        .default(Text("Files")) {
                            isShowingFilePicker = true
                        },
                        .cancel()
                    ]
                )
              
            }
           
        }
    }
    
    private func addImageIfSelected() {
        guard let selectedImage else { return }
        uiImages.append(selectedImage)
        self.selectedImage = nil
        addItemCallback?()
    }
    
    private func addFileIfSelected() {
        guard let selectedFileURL else { return }
        files.append(selectedFileURL)
        self.selectedFileURL = nil
        addItemCallback?()
    }
    
    @ViewBuilder
    private func DeleteButton(_ index: Int, isImage: Bool = true) -> some View {
        VStack {
            HStack {
                Spacer()
                if allowDeletion {
                    Button {
                        if isImage {
                            uiImages.remove(at: index)
                            deleteItemCallback?()
                        } else {
                            files.remove(at: index)
                            deleteItemCallback?()
                        }
                        deleteItemCallback?()
                    } label: {
                        deleteItemLabel()
                    }
                }
            }
            Spacer()
        }
        .offset(x: 3, y: -6)
    }
}

// Enum for specifying the upload mode
public enum UploadMode {
    case pictures
    case documents
    case both
}


// Supporting Views
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

public struct SPFilePreview: View {
    var fileURL: URL
    
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: 100, height: 100)
                .shadow(color: .gray.opacity(0.4), radius: 8, x: 4, y: 4)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                        Text(fileURL.lastPathComponent)
                            .lineLimit(1)
                            .font(.caption)
                            .padding(.horizontal, 8)
                    }
                }
        }
    }
}

public struct SPAddItemLabel: View {
    var uploadMode: UploadMode = .pictures
    public init(uploadMode: UploadMode = .both) {
        self.uploadMode = uploadMode
    }

    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: 100, height: 100)
            .shadow(color: .gray.opacity(0.4), radius: 8, x: 4, y: 4)
            .overlay(
                Image(systemName: uploadMode == .pictures ? "camera" : "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: uploadMode == .pictures ? 50 : 28, height: uploadMode == .pictures ? 50 : 28)
                    .foregroundStyle(Color.black.opacity(0.6))
            )
    }
}

public struct SPDeleteItemLabel: View {
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
    @State private var files = [URL]()
    
    public var body: some View {
        SnapPix(
            uiImages: $uiImages, files: $files,
            uploadMode: .pictures,
            allowDeletion: true,
            addItemCallback: { print("Nice! Item sent 🚀")}
        )
    }
}

#Preview("Default implementation") {
    ExampleView()
}
