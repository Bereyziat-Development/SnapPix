# SnapPix
SnapPix is a Swift package providing a versatile image picker component for SwiftUI applications. It enables users to select images from their device or take photos using the camera. SnapPix offers a range of customization options to seamlessly integrate into your project.

## Requirements
iOS 15 or later
Swift 5.5 or later

## Installation
### Swift Package Manager
You can easily integrate SnapPix using the Swift Package Manager. Follow these simple steps:

Open your project in Xcode.
Navigate to File > Swift Packages > Add Package Dependency.
Enter the package repository URL: https://github.com/Bereyziat-Development/SnapPix
Click Next and follow the remaining steps to add the package to your project.
## Usage
1. Import the necessary modules:

```swift
import SwiftUI
import SnapPix
```
2. Create a binding to an array of UIImage for managing selected images:
```swift
@State private var selectedImages: [UIImage] = []
```
## Example
For a quick start, you can use the provided ready-to-use example:
   ```swift
struct ContentView: View {
    @Binding var uIImages: [UIImage]
    var body: some View {
        VStack {
            SnapPix(uIImages: $uIImages)
           
     
        }
```
Customize the appearance of SnapPix by adjusting properties like image count, gradient colors, corner radius, and more.
```swift
      SnapPix(uIImages: <#T##Binding<[UIImage]>#>, imageCount: <#T##Int#>, cameraImage: <#T##Image#>, gradientColor1: <#T##Color#>, gradientColor2: <#T##Color#>, imageCornerRadius: <#T##CGFloat#>, frameHeight: <#T##CGFloat#>, frameWidth: <#T##CGFloat#>, colorFill: <#T##Color#>, imageHeight: <#T##CGFloat#>, gridMinumum: <#T##CGFloat#>, spacing: <#T##CGFloat#>)
           
```
![Simulator Screen Recording - iPhone 15 Pro - 2023-10-17 at 15 16 34](https://github.com/Bereyziat-Development/SnapPix/assets/101000022/a6eef1a4-3f4f-47cf-9b91-20d068058a19)


## License
This library is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

---
