import UIKit


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
