import UIKit

//class for resizing image and make thumbnails

enum ImageSizes: String, CaseIterable {
    case smallImages, mediumImages, largeImages, originImages

    var targetSize: CGSize? {
        switch self {
        case .smallImages: return CGSize(width: 75, height: 75)
        case .mediumImages: return CGSize(width: 150, height: 150)
        case .largeImages: return CGSize(width: 400, height: 400)
        case .originImages: return nil
        }
    }
}

enum ImagesManager {
    static let dirName = "originImages"
    static func imageExists(withId id: String) -> Bool {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = documentDirectory.appendingPathComponent(ImagesManager.dirName)
        let pngFilepath   = folder.appendingPathComponent("\(id).png").path()
        let jpegFilepath  = folder.appendingPathComponent("\(id).jpeg").path()
        
        return fileManager.fileExists(atPath: pngFilepath) || fileManager.fileExists(atPath: jpegFilepath)
    }


    static func resizeImage(image: UIImage, targetSize: ImageSizes) -> UIImage {
        let size = image.size
        if let targetSize = targetSize.targetSize {

            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height

            let newSize =
                widthRatio > heightRatio
                ? CGSize(
                    width: size.width * heightRatio,
                    height: size.height * heightRatio
                )
                : CGSize(
                    width: size.width * widthRatio,
                    height: size.height * widthRatio
                )

            let rect = CGRect(origin: .zero, size: newSize)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? image
        }
        return image
    }
    

    static func saveImage(
        image: UIImage?,
        id: String,
        type: GlobalProperties.ImageType
    )  {
        guard let image else { return }
        
        let dir = createCustomDirectory(folderName: ImagesManager.dirName)
        
        _ = saveImageToDirectory(
            image: image,
            directory: dir,
            id: id,
            type: type
        )
    }

    static func saveImageToDirectory(
        image: UIImage?,
        directory: URL?,
        id: String,
        type: GlobalProperties.ImageType
    ) -> URL? {
        guard let image = image,
              let directory = directory else { return nil }
        let fileExtension = (type == .club || type == .broadcastSchema || type == .obvan) ? "png" : "jpeg"
        let fileURL = directory.appendingPathComponent("\(id).\(fileExtension)")
        //png flow
        if (type == .club || type == .broadcastSchema || type == .obvan) {
            guard let data = image.pngData() else {
                print("cant load pngdata")
                return nil
            }
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        } else {
            // jpeg flow
            guard let data = image.jpegData(compressionQuality: 1) else {
                return nil
            }
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                print("error: \(error)")
                return nil
            }
        }
    }

    static func loadImage(id: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        let directoryPath = documentDirectory.appendingPathComponent(ImagesManager.dirName)
        let pngFilepath   = directoryPath.appendingPathComponent("\(id).png")
        let jpegFilepath  = directoryPath.appendingPathComponent("\(id).jpeg")
        
//        print(directoryPath)
        
        if fileManager.fileExists(atPath: pngFilepath.path){
            if let image = UIImage(contentsOfFile: pngFilepath.path)?.copy() as? UIImage {
                return image
            } else {
                print("Wrong png data")
                return nil
            }
        } else if fileManager.fileExists(atPath: jpegFilepath.path){
            if let image = UIImage(contentsOfFile: jpegFilepath.path)?.copy() as? UIImage {
                return image
            } else {
                print("Wrong jpeg data")
                return nil
            }
        } else {
            print("File doesn't exist when loading: \(pngFilepath.lastPathComponent) or \(jpegFilepath.lastPathComponent)")
            return nil
        }
    }

    static func removeImageFromDevice(withId id: String) -> Bool {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        var success = true
        
            let directory = documentDirectory.appendingPathComponent(ImagesManager.dirName)
            let pngURL = directory.appendingPathComponent("\(id).png")
            let jpegURL = directory.appendingPathComponent("\(id).jpeg")

            do {
                if fileManager.fileExists(atPath: pngURL.path) {
                    try fileManager.removeItem(at: pngURL)
                } else if fileManager.fileExists(atPath: jpegURL.path) {
                    try fileManager.removeItem(at: jpegURL)

                } else {
                    print("File doesn't exist: id: \(id)")
                    success = false
                }
            } catch {
                print("Error removing file: \(error.localizedDescription)")
                success = false
            }
        return success
    }
 
    static func createCustomDirectory(folderName: String) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let customDirectory = documentsDirectory.appendingPathComponent(
            folderName
        )

        if !fileManager.fileExists(atPath: customDirectory.path) {
            do {
                try fileManager.createDirectory(
                    at: customDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return customDirectory
            } catch {
                print(
                    "Error creating custom directory: \(error.localizedDescription)"
                )
                return nil
            }
        }
        return customDirectory
    }
}
