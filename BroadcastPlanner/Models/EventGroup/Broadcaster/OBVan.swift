import Foundation

struct OBVan: Codable, Identifiable,BPDataProtocol {
    var id: String
    var name: String
    var imageId: String
    
    //obvan units template
    // TODO:  may be refactor this later
//    var units: [OBVanUnit]

}
