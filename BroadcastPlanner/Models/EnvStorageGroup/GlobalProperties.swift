//import Foundation
import UIKit

// global  constants : properties, string, localizeble strings, network links

struct GlobalProperties {
 
    enum Path: String{
        case members, broadcasts, venues, clubs, obvans, images, templates, cameras, sounds, lights, hardwares, none
    }
    
    enum PublishChanges: String{
        case currentUser, members, broadcasts, venues, clubs, obvans, images, cameras, sounds, lights, hardwares, templates, venuePoint, crew, none
    }
    
    enum ImageType: String{
        case member, venueTemplate, club, venue, obvan, venuePreview, obvanPreview, none
    }
    
    
    //just for tests
    static var randomClubImage: UIImage {
        UIImage(named: clubNames.randomElement()!)!}
    
    static let clubNames: [String] = ["Chernomorets","Dynamo","Ingulets","Krivbass"]
}


