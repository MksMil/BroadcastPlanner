import UIKit

struct ClubDTO: Codable, Identifiable,BPDataProtocol{
    var id: String
    var title: String
    var contacts: String = ""
    var urlString: String = ""
    var imageLogoID: String?
    var homeLocationID: String?
    
}
