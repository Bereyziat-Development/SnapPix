//
//  AddPhotos.swift
//
//
//  Created by Szymon Wnuk on 17/10/2023.
//

import SwiftUI
@available(iOS 15.0, *)
/// A SwiftUI view that allows users to select images from their device or camera.

public struct SnapPix: View {
    @State private var isShowingImageSourceTypeActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var selectedPicture: UIImage?
    var canAddImage: Bool { uIImages.count < imageCount }
    
    
    //Design of library
    @Binding var uIImages: [UIImage]
    var imageCount: Int = 5
    var cameraImage: Image = Image(systemName: "camera")
    var gradientColor1: Color = .black
    var gradientColor2: Color = .black
    var imageCornerRadius: CGFloat = 25
    var frameHeight: CGFloat = 110
    var frameWidth: CGFloat = 110
    var colorFill: Color = .white
    var imageHeight: CGFloat = 46
    
    //Columns design
    var gridMinumum: CGFloat = 100
    var spacing: CGFloat = 16
    
    
    /// Initializes a SnapPix view.
    /// - Parameters:
    ///   - uIImages: A binding to an array of UIImages.
    ///   - imageCount: The maximum number of images allowed (default is 5).
    ///   - cameraImage: The image to be displayed as a placeholder for the camera option (default is a camera icon).
    ///   - gradientColor1: The first color of the gradient used for the camera image placeholder (default is black).
    ///   - gradientColor2: The second color of the gradient used for the camera image placeholder (default is black).
    ///   - imageCornerRadius: The corner radius of the images (default is 25).
    ///   - frameHeight: The height of the image frame (default is 110).
    ///   - frameWidth: The width of the image frame (default is 110).
    ///   - colorFill: The background color of the image frames (default is white).
    ///   - imageHeight: The height of the camera image (default is 46).
    ///   - gridMinumum: The minimum width for the grid columns (default is 100).
    ///   - spacing: The spacing between images in the grid (default is 16)
    ///
    public init(uIImages: Binding<[UIImage]>,
                imageCount: Int = 5,
                cameraImage: Image = Image(systemName: "camera"),
                gradientColor1: Color = .black,
                gradientColor2: Color = .black,
                imageCornerRadius: CGFloat = 25,
                frameHeight: CGFloat = 110,
                frameWidth: CGFloat = 110,
                colorFill: Color = .white,
                imageHeight: CGFloat = 46,
                gridMinumum: CGFloat = 100,
                spacing: CGFloat = 16) {
        self._uIImages = uIImages
        self.imageCount = imageCount
        self.cameraImage = cameraImage
        self.gradientColor1 = gradientColor1
        self.gradientColor2 = gradientColor2
        self.imageCornerRadius = imageCornerRadius
        self.frameHeight = frameHeight
        self.frameWidth = frameWidth
        self.colorFill = colorFill
        self.imageHeight = imageHeight
        self.gridMinumum = gridMinumum
        self.spacing = spacing
    }
    
    
    public  var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: gridMinumum))], spacing: spacing) {
                ForEach(uIImages.indices, id: \.self) { index in
                    Image(uiImage: uIImages[index])
                        .resizable()
                        .frame(width: frameWidth, height: frameHeight)
                        .background(colorFill)
                        .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius))
                }
                if canAddImage {
                    Button {
                        self.isShowingImageSourceTypeActionSheet = true
                    } label: {
                        CameraPlaceholder(image: cameraImage, gradientColor1: gradientColor1, gradientColor2: gradientColor2, radius: imageCornerRadius, frameHeight: frameHeight, frameWidth: frameWidth, fill: colorFill, imageHeight: imageHeight)
                        
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
    public  func CameraPlaceholder(image: Image, gradientColor1: Color, gradientColor2: Color, radius: CGFloat, frameHeight: CGFloat, frameWidth: CGFloat, fill: Color, imageHeight: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(fill)
            .frame(width: frameWidth, height: frameHeight)
            .overlay(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: imageHeight)
                    .foregroundStyle(
                        .linearGradient(
                            Gradient(
                                colors: [gradientColor1, gradientColor2]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
    }
}




@available(iOS 15.0, *)
#Preview {
    SnapPix(uIImages: .constant([UIImage(systemName: "pencil")!]))
    
}
