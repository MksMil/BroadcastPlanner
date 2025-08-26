import UIKit
//actor?
actor ImageCacher {
    let logger  = LoggerFactory.logger(for: LogCategory.images)
    
    var cachedImages: [String: [ImageSizes:UIImage]] = [:]
    
    func getImage(id: String, size: ImageSizes) async -> UIImage?{
        guard !id.isEmpty else {
            logger.error("request with empty id")
            return nil }
        
        if let image = cachedImages[id]?[size]{
            logger.debug("cache success: get image of \(size.rawValue) size with id: \(id)")
            return image
        } else {
            //fetch image from localStorage and add it to cache
            if let newImage = ImagesManager.loadImage(id: id){
                let resizedImage = ImagesManager.resizeImage(image: newImage, targetSize: size)
                cachedImages[id,default: [:]] = [size:resizedImage]
                logger.debug("add to cache success: put image of \(size.rawValue) size to cache with id: \(id)")
                return resizedImage
            } else {
                logger.debug("cache failure for image with id: \(id)")
                return nil
            }
        }
    }
    
    //dont'n use directly - for tech
    func getOrigin(id: String) -> UIImage?{
        cachedImages[id]?[ImageSizes.originImages]
    }
    
    func getAndCache(id: String) -> UIImage?{
        if let image = cachedImages[id]?[ImageSizes.originImages]{
            return image
        } else if let image = ImagesManager.loadImage(id: id){
            cachedImages[id]?[ImageSizes.originImages] = image
            return image
        } else {
            return nil
        }
    }
    
    func saveImage(uiimage: UIImage, id: String, type: GlobalProperties.ImageType){
        cachedImages[id] = [.originImages:uiimage]
        ImageSizes.allCases.forEach { size in
            if size != .originImages{
                let image = ImagesManager.resizeImage(image: uiimage, targetSize: size)
                cachedImages[id]?[size] = image//[.originImages:uiimage]
            }
        }
        print("image with id: \(id) cached ...\(cachedImages[id]?[.originImages] != nil)")
        Task{
            ImagesManager.saveImage(image: uiimage, id: id, type: type)
        }
    }
    
    func removeImage(id: String){
        guard !id.isEmpty else { return }
        cachedImages[id] = nil
        let isRemoved = ImagesManager.removeImageFromDevice(withId: id)
        #if DEBUG
        logger.debug("Image with \(id) \(isRemoved ? "removed":"not removed") from local storage")
        #endif
    }
    
    func clearCache(){
        logger.debug("image cache cleared")
        cachedImages = [:]
    }
}
