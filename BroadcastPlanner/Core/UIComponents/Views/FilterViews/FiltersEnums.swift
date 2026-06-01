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
enum BPObvanPositionFilter: String, Customfilter {
    case all          = "square.grid.3x3.fill"
    case director     = "megaphone.fill"
//    case assistant    = "person.badge.plus"
    case replayOp     = "arrow.counterclockwise.circle"
    case graphicEd    = "pencil.and.outline"
    case soundDirector = "waveform.and.mic"
    
    var id: Self { self }
}

enum FilterEventOwnerCases: String, Customfilter {
  case notFiltered    = "square.stack"
  case userParticipation = "figure.wave"
  case userOwned      = "star.fill"
  
  var id: Self { self }
  // TODO: case with caledar date : filter with date ( case calendar(let date) )
}

enum FilterEventUserCases: String, Customfilter {
    case notFiltered = "calendar"
    case userPartisipation = "calendar.badge.checkmark"
    
    var id: Self { self }
    // TODO: case with caledar date : filter with date ( case calendar(let date) )
}
