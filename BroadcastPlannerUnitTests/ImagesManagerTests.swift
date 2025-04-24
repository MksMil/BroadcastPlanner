import XCTest
@testable import BroadcastPlanner
import UIKit

final class ImagesManagerTests: XCTestCase {

    func testResizeImageReturnsCorrectSize() {
        let originalImage = UIImage(systemName: "star.fill")!
        let resizedImage = ImagesManager.resizeImage(image: originalImage, targetSize: .smallImages)

        XCTAssertNotEqual(originalImage.size, resizedImage.size)
        XCTAssertLessThanOrEqual(resizedImage.size.width, 75)
        XCTAssertLessThanOrEqual(resizedImage.size.height, 75)
    }

    func testResizeImagesReturnsAllSizes() {
        let image = UIImage(systemName: "star.fill")!
        let resized = ImagesManager.resizeImages(image: image)

        XCTAssertEqual(resized.count, ImageSizes.allCases.count)
        ImageSizes.allCases.forEach {
            XCTAssertNotNil(resized[$0])
        }
    }

    func testSaveAndLoadImage() {
        let image = UIImage(systemName: "star.fill")!
        let id = UUID().uuidString
        let type = GlobalProperties.ImageType.eventTemplate
        
        ImagesManager.saveResizedImages(image: image, id: id, type: type)

        ImageSizes.allCases.forEach { size in
            let loadedImage = ImagesManager.loadImage(imageSize: size, id: id)
            let exist = ImagesManager.imageExists(withId: id)
            XCTAssertTrue(exist)
            XCTAssertNotNil(loadedImage, "Image not loaded for size: \(size)")
        }

        _ = ImagesManager.removeImageFromDevice(withId: id)
    }

    func testRemoveImage() {
        let image = UIImage(systemName: "star.fill")!
        let id = UUID().uuidString
        let type = GlobalProperties.ImageType.club

        ImagesManager.saveResizedImages(image: image, id: id, type: type)
        let removed = ImagesManager.removeImageFromDevice(withId: id)
        XCTAssertTrue(removed)

        ImageSizes.allCases.forEach { size in
            let loaded = ImagesManager.loadImage(imageSize: size, id: id)
            XCTAssertNil(loaded)
        }
    }
}
