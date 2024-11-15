//
//  SnapPix.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI
@available(iOS 13.0, *)
/// A SwiftUI view that allows users to select images from their device or camera.

public struct SnapPix<
    ImagePreview: View,
    AddItemLabel: View,
    DeleteItemLabel: View,
    FilePreview: View
>: View {
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var isShowingFilePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @State private var selectedFileURL: URL?
    @State private var showPermissionAlert = false
    @State private var isShowingFileSizeAlert = false
    @ViewBuilder private var imagePreview: (Image) -> ImagePreview
    @ViewBuilder private var filePreview: (URL) -> FilePreview
    @ViewBuilder private var addItemLabel: () -> AddItemLabel
    @ViewBuilder private var deleteItemLabel: () -> DeleteItemLabel
    private var addItemCallback: (() -> Void)?
    private var deleteItemCallback: (() -> Void)?
    
    // Features related variables
    @Binding private var uiImages: [UIImage]
    @Binding private var files: [URL]
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
    ///   - uiImages: A binding to an array of UIImages.
    ///   - maxImageCount: The maximum number of images allowed (default is 5).
    ///   - gridMin: The minimum width for the grid columns (default is 100).
    ///   - spacing: The spacing between images in the grid (default is 16)
    ///
    public init(
        uiImages: Binding<[UIImage]>,
        files: Binding<[URL]> = .constant([]),
        maxImageCount: Int = 5,
        gridMin: CGFloat = 100,
        spacing: CGFloat = 16,
        allowDeletion: Bool = false,
        addItemCallback: (() -> Void)? = nil,
        deleteItemCallback: (() -> Void)? = nil,
        @ViewBuilder imagePreview: @escaping (Image) -> ImagePreview = {
            image in SPImagePreview(image: image)
        },
        @ViewBuilder filePreview: @escaping (URL) -> FilePreview = {
            fileURL in SPFilePreview(fileURL: fileURL)
        },
        @ViewBuilder addItemLabel: @escaping () -> AddItemLabel = { SPAddItemLabel() },
        @ViewBuilder deleteItemLabel: @escaping () -> DeleteItemLabel = { SPDeleteItemLabel() }
    ) {
        self._uiImages = uiImages
        self._files = files
        self.maxImageCount = maxImageCount
        self.gridMin = gridMin
        self.spacing = spacing
        self.allowDeletion = allowDeletion
        self.imagePreview = imagePreview
        self.filePreview = filePreview
        self.deleteItemLabel = deleteItemLabel
        self.addItemLabel = addItemLabel
        self.addItemCallback = addItemCallback
        self.deleteItemCallback = deleteItemCallback
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
                            DeleteButton(index)
                        }
                }
                ForEach(Array(files.enumerated()), id: \.offset) { index, fileURL in
                    filePreview(fileURL)
                        .overlay {
                            DeleteButton(index, isImage: false)
                        }
                }
                if canAddItem {
                    Button {
                        isShowingImageSourceTypeActionSheet = true
                    } label: {
                        addItemLabel()
                    }
                }
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
            DocumentPicker(fileURL: $selectedFileURL, isShowingFileSizeError: $isShowingFileSizeAlert)
        }
        .actionSheet(isPresented: $isShowingImageSourceTypeActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Choose pictures or files"),
                message: Text("Please choose pictures or files from your gallery"),
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
                            isShowingFilePicker = true
                        }
                    ),
                    ActionSheet.Button.cancel()
                ]
            )
        }
        .alert(isPresented: $isShowingFileSizeAlert) {
            Alert(
                title: Text("Error"),
                message: Text("The max file size is 2MB."),
                dismissButton: .default(Text("OK"))
            )
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
    public init() {}
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: 100, height: 100)
            .shadow(color: .gray.opacity(0.4), radius: 8, x: 4, y: 4)
            .overlay(
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
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
            allowDeletion: true,
            addItemCallback: { print("Nice! Item sent 🚀")}
        )
    }
}

#Preview("Default implementation") {
    ExampleView()
}
