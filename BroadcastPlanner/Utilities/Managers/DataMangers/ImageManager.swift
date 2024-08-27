import UIKit
import FirebaseStorage

class ImageManager {
    
    let storage: Storage
    
    init(){
        self.storage = Storage.storage()
    }
    
    func loadImage(id: String) -> UIImage?{
        return nil
    }
    
    func uploadImage(id: String, image: UIImage, path: ImagePath) async {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        //save to local
        if let url = getPath(name: path){
            if !FileManager.default.fileExists(atPath: url.relativePath){
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                }catch{
#if DEBUG
                    print("DEBUG: directory creation to saving image to local storage error: \(error)")
#endif
                }
            }
            FileManager.default.createFile(atPath: url.appendingPathComponent("\(id).jpeg").relativePath,
                                           contents: imageData)
        }
        
        //save to global
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(ImagePath.userImage.rawValue)/\(id)")
        imageRef.putData(imageData)

    }
    
    // local directory path for save image
    func getPath(name: ImagePath) -> URL? {
        guard let path = FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
                .first?
            .appending(path: "\(name.rawValue)")
        else {
            return nil
        }
        return path
    }
}
