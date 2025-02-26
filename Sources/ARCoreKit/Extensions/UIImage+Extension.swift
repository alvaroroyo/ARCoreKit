import UIKit
import AVFoundation

public extension UIImage {
    var base64PNG: String? {
        guard let data = pngData() else { return nil }
        return data.base64EncodedString(options: .lineLength64Characters)
    }

    var base64JPG: String? {
        guard let data = jpegData(compressionQuality: 0.8) else { return nil }
        return data.base64EncodedString(options: .lineLength64Characters)
    }

    convenience init?(base64: String) {
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
        self.init(data: data)
    }
}

public extension UIImage {
    func resize(_ maxSize: CGFloat) -> UIImage {
            // Keep aspect ratio
            let maxSize = CGSize(width: maxSize, height: maxSize)

            let availableRect = AVFoundation.AVMakeRect(
                aspectRatio: self.size,
                insideRect: .init(origin: .zero, size: maxSize)
            )
            let targetSize = availableRect.size

            // Set scale of renderer so that 1pt == 1px
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

            // Resize the image
            let resized = renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: targetSize))
            }

            return resized
        }
}
