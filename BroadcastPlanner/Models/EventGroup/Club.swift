import UIKit

struct Club: Codable, Hashable, Identifiable,BPDataProtocol{
    var id: String
    var title: String
    var contacts: String = ""
    var urlString: String = ""
    var imageLogoID: String?
    var homeLocationID: String?
    
}

extension Club: Equatable{
    static func == (lhs: Club, rhs: Club) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Prepare data to newtwork save
extension Club{
    
    static func mapToClub(localClub: LocalClub) -> Club{
        let club = Club(id: localClub.viewId,
                        title: localClub.viewTitle,
                        contacts: localClub.viewContacts,
                        urlString: localClub.viewUrl,
                        imageLogoID: localClub.imageLogo?.viewId,
                        homeLocationID: localClub.homeLocation?.viewId)
        return club
    }
}
