import Foundation
protocol Customfilter: CaseIterable, Identifiable, Codable, RawRepresentable {}

// MARK: - Filter venuePoints
enum BPEventPlanPointStadiumFilter: String, Customfilter //CaseIterable,Identifiable, Codable
{
    case all = "square.grid.3x3.fill"
    case person = "person"
    case cam = "video.fill"
    case mic = "mic.circle"
    case light = "warninglight"
    
    
    var id: Self { self }
}

enum BPEventPlanPointCarFilter: String, Customfilter//CaseIterable,Identifiable, Codable
{
    case all = "square.grid.3x3.fill"
    case dir = "brain.head.profile"//"crown" //movieclapper //brain
    case rep = "arcade.stick.console"
    case grf = "photo.tv"
    case sou = "headphones"
    
    var id: Self { self }
}

enum FilterEventOwnerCases: String, Customfilter {
    case notFiltered = "list.bullet" /*"calendar"*/ /*"rectangle.stack.fill"*/
    case userOwned = "crown.fill" /*"pencil.and.list.clipboard"*/ /*"person.2.fill"*/
    case userPartisipation = "person.fill.checkmark" /*"calendar.badge.checkmark"*/ /*"person.badge.key.fill"*/
    
    var id: Self { self }
    // TODO: case with caledar date : filter with date ( case calendar(let date) )
}

enum FilterEventUserCases: String, Customfilter {
    case notFiltered = "calendar"
    case userPartisipation = "calendar.badge.checkmark"
    
    var id: Self { self }
    // TODO: case with caledar date : filter with date ( case calendar(let date) )
}
