import UIKit


//class for resizing image and make thumbnails

class ImageOptimizator{
    
    func makeThumbnailFromImage(uiimage: UIImage, forSize size: CGSize) -> UIImage{
        
        
        
        
        return UIImage()
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio > heightRatio ?
                      CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
                      CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)

        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    
}
