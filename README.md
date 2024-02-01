# SnapPix

SnapPix is a SwiftUI component for iOS that simplifies image selection and display within your app. Users can easily choose images from their device or camera, and the selected images are presented in a customizable grid layout.

## Features

- **Image Selection:** Allow users to pick images from their photo library or take new ones with the camera.
- **Grid Display:** Display selected images in a customizable grid layout.
- **Add and Delete Images:** Enable users to add new images to the grid and delete existing ones.
- **Customization:** Customize the appearance of image previews, add labels, and delete labels.

## Installation

To integrate SnapPix into your project, simply add the `SnapPix.swift` file to your Xcode project.

## Usage

Here's a basic example of how to use SnapPix in your SwiftUI view:

```swift
import SnapPix

struct ExampleView: View {
    @State private var uiImages = [UIImage]()

    var body: some View {
        SnapPix(
            uiImages: $uiImages,
            allowDeletion: true,
            addImageCallback: { print("Image added!") }
        )
    }
}
```
## Initialization

You can customize SnapPix by providing various parameters during initialization. Here's an example:

```swift
SnapPix(
    uiImages: $uiImages,
    maxImageCount: 5,
    gridMin: 100,
    spacing: 16,
    allowDeletion: true,
    addImageCallback: { print("Image added!") },
    deleteImageCallback: { print("Image deleted!") },
    imagePreview: { image in
        // Custom image preview view
        SPImagePreview(image: image)
    },
    addImageLabel: {
        // Custom add image label view
        SPAddImageLabel()
    },
    deleteImageLabel: {
        // Custom delete image label view
        SPDeleteImageLabel()
    }
)
```


https://github.com/Bereyziat-Development/SnapPix/assets/72884798/25884ac3-432a-40e5-bfef-024d1874c2ac



## License

SnapPix is released under the MIT License. See [LICENSE](LICENSE) for details.
