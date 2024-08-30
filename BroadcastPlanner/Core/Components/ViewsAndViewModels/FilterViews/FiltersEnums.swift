import Foundation
protocol Customfilter: CaseIterable, Identifiable, Codable {}

// MARK: - Filter points
enum BPEventPlanPointStadiumFilter: String, Customfilter //CaseIterable,Identifiable, Codable
{
    case all = "square.grid.3x3.fill"
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

enum FilterEventCases: String, Customfilter {
    case notFiltered = "calendar"
    case userOwned = "pencil.and.list.clipboard"
    case userPartisipation = "calendar.badge.checkmark"
    
    var id: Self { self }
    // TODO: case with caledar date : filter with date ( case calendar(let date) )
}
