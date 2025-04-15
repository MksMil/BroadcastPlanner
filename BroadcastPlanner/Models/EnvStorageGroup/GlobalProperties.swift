import Foundation

// global  constants : properties, string, localizeble strings, network links

struct GlobalProperties {
 
    enum Path: String{
        case users, events, locations, clubs, obvans, images, templates, cameras, sounds, lights, hardwares,  none
    }
    
    enum PublishChanges: String{
        case currentUser, users, events, locations, clubs, obvans, images, cameras, sounds, lights, hardwares, templates, point, unit, none
    }
    
    enum ImageType: String{
        case user, eventTemplate, club, location, obvan, locationPreview, obvanPreview, none
    }
}

