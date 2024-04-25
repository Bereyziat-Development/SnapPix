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
    AddImageLabel: View,
    DeleteImageLabel: View
>: View {
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedImage: UIImage?
    @ViewBuilder private var imagePreview: (Image) -> ImagePreview
    @ViewBuilder private var addImageLabel: () -> AddImageLabel
    @ViewBuilder private var deleteImageLabel: () -> DeleteImageLabel
    private var addImageCallback: (() -> Void)?
    private var deleteImageCallback: (() -> Void)?
    
    // Features related variables
    @Binding private var uiImages: [UIImage]
    private var allowDeletion: Bool = false
    private var maxImageCount: Int = 5
   
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
    ///
    public init(
        uiImages: Binding<[UIImage]>,
        maxImageCount: Int = 5,
        gridMin: CGFloat = 100,
        spacing: CGFloat = 16,
        allowDeletion: Bool = false,
        addImageCallback: (() -> Void)? = nil,
        deleteImageCallback: (() -> Void)? = nil,
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
        self.imagePreview = imagePreview
        self.deleteImageLabel = deleteImageLabel
        self.addImageLabel = addImageLabel
        self.addImageCallback = addImageCallback
        self.deleteImageCallback = deleteImageCallback
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
                        isShowingImageSourceTypeActionSheet = true
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
                sourceType: sourceType!,
                uiImage: $selectedImage,
                isPresented: $isShowingImagePicker
            )
        }
        .actionSheet(isPresented: $isShowingImageSourceTypeActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Choose pictures"),
                message: Text("Please choose pictures from your gallery"),
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
                    ActionSheet.Button.cancel()
                ]
            )
        }
    }
    
    private func addImageIfSelected() {
        guard let selectedImage else { return }
        uiImages.append(selectedImage)
        self.selectedImage = nil
        addImageCallback?()
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
