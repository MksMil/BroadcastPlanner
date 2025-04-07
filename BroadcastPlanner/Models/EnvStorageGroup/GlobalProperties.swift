import Foundation

// global  constants : properties, string, localizeble strings, network links

struct GlobalProperties {
 
    enum Path: String{
        case users, events, locations, clubs, broadcasters, obvans, images, cameras, sounds, lights, hardwares, templates, none
    }
    
    enum PublishChanges: String{
        case currentUser, users, events, locations, clubs, broadcasters, obvans, images, cameras, sounds, lights, hardwares, templates,localPoint, obvanUnit, none
    }
    
    enum ImageType: String{
        case user, eventTemplate, club, broadcaster, location, obvan, locationPreview, obvanPreview, none
    }
}

