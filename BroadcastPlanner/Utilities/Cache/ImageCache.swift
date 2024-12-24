//
//  ImageCache.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 13.12.2024.
//


import SwiftUI

class ImageCache {
    
    var cachedImages: [String: [Image]] = [:]

    func getImage(id: String, size: ImageSizes) -> Image{
        if let images = cachedImages[id]{
            switch size {
                case .smallImages:
                    return images[0]
                case .mediumImages:
                    return images[1]
                case .largeImages:
                    return images[2]
                case .originImages:
                    return images[3]
            }
        } else {
            //fetch image from localStorage and add it to cache
            if let newImages = fetchImageFromLocalWithId(id){
                cachedImages[id] = newImages
                switch size {
                    case .smallImages:
                        return newImages[0]
                    case .mediumImages:
                        return newImages[1]
                    case .largeImages:
                        return newImages[2]
                    case .originImages:
                        return newImages[3]
                }
            }
            return Image(systemName: "plus")
        }
    }
    
    func fetchImageFromLocalWithId(_ id: String) -> [Image]?{
        
        return []
    }
}
