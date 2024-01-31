//
//  AddPhotos.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI
@available(iOS 15.0, *)
/// A SwiftUI view that allows users to select images from their device or camera.

public struct SnapPix<Label: View>: View {
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedPicture: UIImage?
    var canAddImage: Bool { uIImages.count < imageCount }
    
    private var imagePreview: ((Image) -> Label)?
    private var xmarkDeletion: (() -> Label)?
    private var canAddImageButton: (() -> Label)?
    
    //Design of library
    @Binding var uIImages: [UIImage]
    @Binding var allowDeletion: Bool
    var imageCount: Int = 5
   
    //Columns design
    var gridMinumum: CGFloat = 100
    var spacing: CGFloat = 16
    
    var hasImagePreview: Bool {
        return imagePreview != nil
    }
    
    var hasXmarkDeletion: Bool {
        return xmarkDeletion != nil
    }
    
    var hasAddImageButton: Bool {
        return canAddImageButton != nil
    }
    
    /// Initializes a SnapPix view.
    /// - Parameters:
    ///   - uIImages: A binding to an array of UIImages.
    ///   - imageCount: The maximum number of images allowed (default is 5).
    ///   - gridMinumum: The minimum width for the grid columns (default is 100).
    ///   - spacing: The spacing between images in the grid (default is 16)
    ///
    public init(uIImages: Binding<[UIImage]>,
                imageCount: Int = 5,
                gridMinumum: CGFloat = 100,
                spacing: CGFloat = 16,
                allowDeletion: Binding<Bool> = Binding.constant(false),
                imagePreview: ((Image) -> Label)? = nil,
                xmarkDeletion: (() -> Label)? = nil,
                canAddImageButton: (() -> Label)? = nil
    ) {
        self._uIImages = uIImages
        self.imageCount = imageCount
        self.gridMinumum = gridMinumum
        self.spacing = spacing
        self._allowDeletion = allowDeletion
        self.imagePreview = imagePreview
        self.xmarkDeletion = xmarkDeletion
        self.canAddImageButton = canAddImageButton
    }
    
    public  var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridMinumum))], spacing: spacing) {
                ForEach(uIImages.indices, id: \.self) { index in
                    if hasImagePreview {
                        if let previewClosure = imagePreview {
                            let previewImage = Image(uiImage: uIImages[index])
                            previewClosure(previewImage)
                                .overlay {
                                    XmarkDeletion(index: index)
                                }
                        }
                    } else {
                        Image(uiImage: uIImages[index])
                            .resizable()
                            .frame(width: 110, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay {
                                XmarkDeletion(index: index)
                            }
                    }
                }
                .onLongPressGesture {
                    allowDeletion.toggle()
                }
                if canAddImage {
                    Button {
                        self.isShowingImageSourceTypeActionSheet = true
                    } label: {
                        if hasAddImageButton {
                            canAddImageButton!()
                        } else {
                            CameraPlaceholder()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: {
            if let selectedPicture {
                uIImages.append(selectedPicture)
            }
            self.selectedPicture = nil
        }) {
            ImagePicker(
                sourceType: sourceType!,
                uiImage: $selectedPicture,
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
                    ), ActionSheet.Button.cancel()
                ]
            )
        }
    }
    
    private func onDismissImagePicker() {
        if let selectedPicture {
            uIImages.append(selectedPicture)
        }
        selectedPicture = nil
    }
    
    @ViewBuilder
    private func XmarkDeletion(index: Int) -> some View {
        VStack {
            HStack {
                Spacer()
                if allowDeletion {
                    Button {
                        uIImages.remove(at: index)
                    } label: {
                        if hasXmarkDeletion {
                            xmarkDeletion!()
                        } else {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            Spacer()
        }
        .offset(x: 3, y: -6)
    }
    
    @ViewBuilder
    public func CameraPlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .frame(width: 110, height: 100)
            .shadow(color: .gray.opacity(0.4), radius: 8, x: 4, y: 4)
            .overlay(
                Image(systemName: "camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
               
                    .frame(height: 46)
                    .foregroundStyle(Color.black.opacity(0.6))
            )
    }
}


#if DEBUG
#Preview {
    SnapPix(uIImages: .constant([UIImage(systemName: "trash")!]), imageCount: 1, gridMinumum: 10, spacing: 10, allowDeletion: .constant(true)) { image in
        Image(systemName: "plus")
    } xmarkDeletion: {
        Image(systemName: "xmark")
    } canAddImageButton: {
        Image(systemName: "book")
    }
}

#Preview {
    SnapPix<EmptyView>(uIImages: .constant([UIImage(systemName: "camera")!]), imageCount: 4, gridMinumum: 100, spacing: 10, allowDeletion: .constant(true))
}
#endif
