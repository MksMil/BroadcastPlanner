import UIKit

//actor ImageCacher {
//    let logger  = LoggerFactory.logger(for: LogCategory.images)
//    
//    var cachedImages: [String: [ImageSizes:UIImage]] = [:]
//    
//    func getImage(id: String, size: ImageSizes) async -> UIImage?{
//        guard !id.isEmpty else {
//            logger.error("request with empty id")
//            return nil }
//        
//        if let image = cachedImages[id]?[size]{
//            logger.debug("cache success: get image of \(size.rawValue) size with id: \(id)")
//            return image
//        } else {
//            //fetch image from localStorage and add it to cache
//            if let newImage = ImagesManager.loadImage(id: id){
//                let resizedImage = ImagesManager.resizeImage(image: newImage, targetSize: size)
//                cachedImages[id,default: [:]] = [size:resizedImage]
//                logger.debug("add to cache success: put image of \(size.rawValue) size to cache with id: \(id)")
//                return resizedImage
//            } else {
//                logger.debug("cache failure for image with id: \(id)")
//                return nil
//            }
//        }
//    }
//    
//    //dont'n use directly - for tech
//    func getOrigin(id: String) -> UIImage?{
//        cachedImages[id]?[ImageSizes.originImages]
//    }
//    
//    func getAndCache(id: String) -> UIImage?{
//        if let image = cachedImages[id]?[ImageSizes.originImages]{
//            return image
//        } else if let image = ImagesManager.loadImage(id: id){
//            cachedImages[id]?[ImageSizes.originImages] = image
//            return image
//        } else {
//            return nil
//        }
//    }
//    
//    func saveImage(uiimage: UIImage, id: String, type: GlobalProperties.ImageType){
//        cachedImages[id] = [.originImages:uiimage]
//        ImageSizes.allCases.forEach { size in
//            if size != .originImages{
//                let image = ImagesManager.resizeImage(image: uiimage, targetSize: size)
//                cachedImages[id]?[size] = image//[.originImages:uiimage]
//            }
//        }
//        print("image with id: \(id) cached ...\(cachedImages[id]?[.originImages] != nil)")
//        Task{
//            ImagesManager.saveImage(image: uiimage, id: id, type: type)
//        }
//    }
//    
//    func removeImage(id: String){
//        guard !id.isEmpty else { return }
//        cachedImages[id] = nil
//        let isRemoved = ImagesManager.removeImageFromDevice(withId: id)
//        #if DEBUG
//        logger.debug("Image with \(id) \(isRemoved ? "removed":"not removed") from local storage")
//        #endif
//    }
//    
//    func clearCache(){
//        logger.debug("image cache cleared")
//        cachedImages = [:]
//    }
//}
actor ImageCacher {
    private let logger = LoggerFactory.logger(for: LogCategory.images)
    private let cache = NSCache<NSString, UIImage>()

    init() {
        cache.totalCostLimit = 50 * 1024 * 1024
        logger.debug("ImageCacher initialized, totalCostLimit: \(50)MB")
    }

    private func cacheKey(id: String, size: ImageSizes) -> NSString {
        "\(id)_\(size.rawValue)" as NSString
    }

    func getImage(id: String, size: ImageSizes) async -> UIImage? {
        guard !id.isEmpty else {
            logger.error("getImage called with empty id")
            return nil
        }

        let key = cacheKey(id: id, size: size)

        if let cached = cache.object(forKey: key) {
            logger.debug("cache hit: id=\(id) size=\(size.rawValue)")
            return cached
        }

        logger.debug("cache miss: id=\(id) size=\(size.rawValue) — loading from disk")

        guard let origin = ImagesManager.loadImage(id: id) else {
            logger.warning("disk miss: id=\(id) — image not found")
            return nil
        }

        let result = ImagesManager.resizeImage(image: origin, targetSize: size)
        let cost = estimateCost(result)
        cache.setObject(result, forKey: key, cost: cost)
        logger.debug("cached: id=\(id) size=\(size.rawValue) cost=\(cost / 1024)KB")
        return result
    }

    func saveImage(uiimage: UIImage, id: String, type: GlobalProperties.ImageType) {
        let key = cacheKey(id: id, size: .originImages)
        let cost = estimateCost(uiimage)
        cache.setObject(uiimage, forKey: key, cost: cost)
        logger.debug("saved to cache: id=\(id) cost=\(cost / 1024)KB")

        Task {
            ImagesManager.saveImage(image: uiimage, id: id, type: type)
            logger.debug("saved to disk: id=\(id)")
        }
    }

    func removeImage(id: String) {
        guard !id.isEmpty else {
            logger.error("removeImage called with empty id")
            return
        }
        ImageSizes.allCases.forEach { size in
            cache.removeObject(forKey: cacheKey(id: id, size: size))
        }
        let isRemoved = ImagesManager.removeImageFromDevice(withId: id)
        logger.debug("removed: id=\(id) fromDisk=\(isRemoved)")
    }

    func clearCache() {
        cache.removeAllObjects()
        logger.debug("cache cleared")
    }

    private func estimateCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else {
            logger.warning("estimateCost: cgImage is nil, returning 0")
            return 0
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}
