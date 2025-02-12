import UIKit

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
    private func getGoodSize(_ maxImageSize: CGFloat) -> CGSize? {
        var size = self.size
        size.height *= scale
        size.width *= scale
        if size.width > size.height, size.width > maxImageSize {
            let newHeight = maxImageSize * size.height / size.width
            return CGSize(width: maxImageSize, height: newHeight)
        } else if size.height > size.width, size.height > maxImageSize {
            let newWidth = maxImageSize * size.width / size.height
            return CGSize(width: newWidth, height: maxImageSize)
        } else if size.height == size.width, size.height > maxImageSize {
            return CGSize(width: maxImageSize, height: maxImageSize)
        } else {
            return nil
        }
    }

    func resizeWithProportions(_ maxSize: CGFloat = 500) -> UIImage {
        if let newSize = getGoodSize(maxSize) {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
            UIGraphicsEndImageContext()
            return newImage
        }
        return self
    }
}
