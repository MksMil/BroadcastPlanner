import UIKit


//class for resizing image and make thumbnails

enum ImageSizes: String, CaseIterable{
    case smallImages, mediumImages, originImages
}

class ImagesManager{
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
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
    func saveResizedImages(image: UIImage?, id: String) -> [String: URL?] {
        // directories for small, medium and large
        guard let image else { return [:]}
        let smallDir = createCustomDirectory(folderName: "\(ImageSizes.smallImages.rawValue)")
        let mediumDir = createCustomDirectory(folderName: "\(ImageSizes.mediumImages.rawValue)")
        let largeDir = createCustomDirectory(folderName: "\(ImageSizes.originImages.rawValue)")

        // resizing image
        let smallImage = resizeImage(image: image, targetSize: CGSize(width: 75, height: 75))
        let mediumImage = resizeImage(image: image, targetSize: CGSize(width: 150, height: 150))
        // save images to local directories
        let smallImageURL = saveImageToDirectory(image: smallImage, directory: smallDir, id: id)
        let mediumImageURL = saveImageToDirectory(image: mediumImage, directory: mediumDir, id: id)
        let largeImageURL = saveImageToDirectory(image: image, directory: largeDir, id: id)
        
        return [
            "\(ImageSizes.smallImages.rawValue)": smallImageURL,
            "\(ImageSizes.mediumImages.rawValue)": mediumImageURL,
            "\(ImageSizes.originImages.rawValue)": largeImageURL
        ]
    }
    
    func saveImageToDirectory(image: UIImage?, directory: URL?, id: String) -> URL? {
        guard let image = image, let directory = directory else { return nil }
        let fileURL = directory.appendingPathComponent(id)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadImage(type: ImageSizes ,id: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filepath =
            documentDirectory.appendingPathComponent("\(type.rawValue)").appendingPathComponent("\(id)")
        if FileManager.default.fileExists(atPath: filepath.path) {
            if let image = UIImage(contentsOfFile: filepath.path) {
                return image
            } else {
                print("Wrong data")
                return nil
            }
        } else {
            print("File doesn't exist: \(filepath.path)")
            return nil
        }
    }
    
    func removeImageFromDevice(withId id: String) -> Bool {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let urls = ImageSizes.allCases.map { imageSize in
            documentDirectory.appendingPathComponent("\(imageSize.rawValue)").appendingPathComponent("\(id)")
        }
        for url in urls{
            do {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                    print("Файл успешно удалён: \(url)")
                }
            } catch {
                print("Error removing image from local: \(error.localizedDescription)")
            }
        }
        return true
    }
    
    func createCustomDirectory(folderName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customDirectory = documentsDirectory.appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: customDirectory.path) {
            do {
                try fileManager.createDirectory(at: customDirectory, withIntermediateDirectories: true, attributes: nil)
                return customDirectory
            } catch {
                print("Error creating custom directory: \(error.localizedDescription)")
                return nil
            }
        }
        return customDirectory
    }
    
    func saveToCustomDirectory(data: Data, folderName: String, fileName: String) -> URL? {
        guard let customDirectory = createCustomDirectory(folderName: folderName) else { return nil }
        let fileURL = customDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file to custom directory: \(error.localizedDescription)")
            return nil
        }
    }
    
}
//extension UIImage {
//    func resize(to size: CGSize) -> UIImage {
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { _ in
//            self.draw(in: CGRect(origin: .zero, size: size))
//        }
//    }
//}
