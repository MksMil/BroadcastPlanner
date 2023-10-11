import Foundation


enum CameraDirection: Double {
    case up
    case down
    case left
    case right
    case oneOclock
    case fiveOclock
    case eightOclock
    case elevenOclock
    
    var directionMultiplier: Double {
        switch self{
        case .up    : 1.5 * .pi
        case .down  : 0.5 * .pi
        case .left  : 1.0 * .pi
        case .right : 0 * .pi
        case .oneOclock: -.pi / 4
        case .fiveOclock:  .pi / 4
        case .eightOclock: .pi * 3 / 4
        case .elevenOclock: -.pi * 3 / 4
        }
    }
}

enum CameraPosition: String, CaseIterable, Identifiable{
    
    var id: Self { self }
    //main upper
    case mainMatch = "Main Match Camera Wide Angle"
    case mainCloseUp = "Main Close Up"
    
    //central pitch
    case pitchSideHalfWay = "Pitch Central Ring"
    
    //stedicams
    case stedicamLHS = "Stedicam Left Side"
    case stedicamRHS = "Stedicam Right Side"
    case reverseStedicamLHS = "Reverse stedicam Left Side"
    case reverseStedicamRHS = "Reverse stedicam Right Side"
    
    //left goal
    case pitchSideBehindGoalLHS = "Left Behind Goal"
    case pitchSideBehindGoalLHSMirror = "Left Behind Goal Mirror"
    case polecamLHS = "Left PoleCam"
    case goalCamLHSLeftCorner = "Goal LHS left"
    case goalCamLHSRightCorner = "Goal LHS right"
    case highBehindGoalLHS = "Left High behind goal"
    
    //right goal
    case pitchSideBehindGoalRHS = "Right Behind Goal"
    case pitchSideBehindGoalRHSMirror = "Right Behind Goal Mirror"
    case polecamRHS = "Right PoleCam"
    case goalCamRHSLeftCorner = "Goal RHS left"
    case goalCamRHSRightCorner = "Goal RHS right"
    case highBehindGoalRHS = "Right High behind goal"
    
    //reverses
    case reverseCentralUpper = "Reverse Central upper tier"
    case reverseCentralLower = "Reverse Central lower tier"
    case secondReverseCentralUpper = "Second Reverse Central upper tier"
    case secondReverseCentralLower = "Second Reverse Central lower tier"
    
    //offsides
    case high16mLHS = "left offside"
    case high16mRHS = "right offside"
    case low16mLHS = "left pitch"
    case low16mRHS = "right pitch"
    
    //beauty shots
    case upperLeftBS = "Upper left Beauty Shot"
    case upperRightBS = "Upper right Beauty Shot"
    case lowerLeftBS = "Lower left Beauty Shot"
    case lowerRightBS = "Lower right Beauty Shot"
    case helicopter = "Helicopter"
    case drone = "Drone"
    
    //goal line cam
    case goalLineLHS = "Left goal line"
    case goalLineRHS = "Right goal line"
    
    //spider cam
    case spiderCam = "Spider cam"
    
    //support
    case teamArrivals = "Team arrivals"
    case flashInterview = "Flash interview"
    case dressingRoom = "Dressing room"
    case pressConference = "Press conference"
    case tunnelCam = "Tunell cam"
}
enum Signal : String{
    case radio
    case cable
}

final class Camera: Hashable, Identifiable, ObservableObject {
    var id = UUID()
    @Published var cameraMan: User = User()
    
   @Published var selected: Bool = false
    {
        didSet{
            print("toggled \(selected)")
        }
    }
    @Published var number: String = ""
    @Published var position: CameraPosition
    @Published var signal: Signal = .cable
    var direction: CameraDirection {
        switch position {
        case .mainMatch:
                return CameraDirection.up
        case .mainCloseUp:
            return CameraDirection.up
        case .pitchSideHalfWay:
            return CameraDirection.up
        case .stedicamLHS:
            return CameraDirection.up
        case .stedicamRHS:
            return CameraDirection.up
        case .reverseStedicamLHS:
            return CameraDirection.down
        case .reverseStedicamRHS:
            return CameraDirection.down
        case .pitchSideBehindGoalLHS:
            return CameraDirection.right
        case .pitchSideBehindGoalLHSMirror:
            return CameraDirection.right
        case .polecamLHS:
            return CameraDirection.right
        case .goalCamLHSLeftCorner:
            return CameraDirection.right
        case .goalCamLHSRightCorner:
            return CameraDirection.right
        case .highBehindGoalLHS:
            return CameraDirection.right
        case .pitchSideBehindGoalRHS:
            return CameraDirection.left
        case .pitchSideBehindGoalRHSMirror:
            return CameraDirection.left
        case .polecamRHS:
            return CameraDirection.left
        case .goalCamRHSLeftCorner:
            return CameraDirection.left
        case .goalCamRHSRightCorner:
            return CameraDirection.left
        case .highBehindGoalRHS:
            return CameraDirection.left
        case .reverseCentralUpper:
            return CameraDirection.down
        case .reverseCentralLower:
            return CameraDirection.down
        case .secondReverseCentralUpper:
            return CameraDirection.down
        case .secondReverseCentralLower:
            return CameraDirection.down
        case .high16mLHS:
            return CameraDirection.up
        case .high16mRHS:
            return CameraDirection.up
        case .low16mLHS:
            return CameraDirection.up
        case .low16mRHS:
            return CameraDirection.up
        case .upperLeftBS:
            return CameraDirection.fiveOclock
        case .upperRightBS:
            return CameraDirection.eightOclock
        case .lowerLeftBS:
            return CameraDirection.oneOclock
        case .lowerRightBS:
            return CameraDirection.elevenOclock
        case .helicopter:
            return CameraDirection.left
        case .drone:
            return CameraDirection.left
        case .goalLineLHS:
            return CameraDirection.up
        case .goalLineRHS:
            return CameraDirection.up
        case .spiderCam:
            return CameraDirection.right
        case .teamArrivals:
            return CameraDirection.right
        case .flashInterview:
            return CameraDirection.right
        case .dressingRoom:
            return CameraDirection.right
        case .pressConference:
            return CameraDirection.right
        case .tunnelCam:
            return CameraDirection.down
//        default: return CameraDirection.right
                
        }
    }
    
    func makeOffset(camH: Double,camW:Double) -> CGSize{
        switch self.position {
        case .mainMatch:
            CGSize(width: 0, height: camH * 1.5)
        case .mainCloseUp:
            CGSize(width: -camW * 0.3, height: camH * 1.5)
            
        case .pitchSideHalfWay:
            CGSize(width: 0, height: camH * 1.1 )
        case .stedicamLHS:
            CGSize(width: -camW * 1.5, height: camH * 1.1)
        case .stedicamRHS:
            CGSize(width: camW * 1.5, height: camH * 1.1)
            
        case .reverseStedicamLHS:
            CGSize(width: -camW * 1.5, height: -camH * 1.1)
        case .reverseStedicamRHS:
            CGSize(width: camW * 1.5, height: -camH * 1.1)
            
        case .pitchSideBehindGoalLHS:
            CGSize(width: -camW * 2.5, height: camH * 0.5)
        case .pitchSideBehindGoalLHSMirror:
            CGSize(width: -camW * 2.5, height: -camH * 0.5)
        case .polecamLHS:
            CGSize(width: -camW * 3, height: 0)
        case .goalCamLHSLeftCorner:
            CGSize(width: -camW * 2, height: -camH * 0.1)
        case .goalCamLHSRightCorner:
            CGSize(width: -camW * 2, height: camH * 0.1)
        case .highBehindGoalLHS:
            CGSize(width: -camW * 4, height: 0)
            
        case .pitchSideBehindGoalRHS:
            CGSize(width: camW * 2.5, height: camH * 0.5)
        case .pitchSideBehindGoalRHSMirror:
            CGSize(width: camW * 2.5, height: -camH * 0.5)
        case .polecamRHS:
            CGSize(width: camW * 3, height: 0)
        case .goalCamRHSLeftCorner:
            CGSize(width: camW * 2, height: camH * 0.1)
        case .goalCamRHSRightCorner:
            CGSize(width: camW * 2, height: -camH * 0.1)
        case .highBehindGoalRHS:
            CGSize(width: camW * 4, height: 0)
            
        case .reverseCentralUpper:
            CGSize(width: 0, height: -camH * 1.5)
        case .reverseCentralLower:
            CGSize(width: 0, height: -camH * 1.1)
        case .secondReverseCentralUpper:
            CGSize(width: -camW * 0.3, height: -camH * 1.5)
        case .secondReverseCentralLower:
            CGSize(width: -camW * 0.3, height: -camH * 1.1)
            
        case .high16mLHS:
            CGSize(width: -camW, height: camH * 1.5)
        case .high16mRHS:
            CGSize(width: camW, height: camH * 1.5)
        case .low16mLHS:
            CGSize(width: -camW, height: camH * 1.1)
        case .low16mRHS:
            CGSize(width: camW, height: camH * 1.1)
            
        case .upperLeftBS:
            CGSize(width: -camW * 4.2, height: -camH * 1.6)
        case .upperRightBS:
            CGSize(width: camW * 4.2, height: -camH * 1.6)
        case .lowerLeftBS:
            CGSize(width: -camW * 4.2, height: camH * 1.6)
        case .lowerRightBS:
            CGSize(width: camW * 4.2, height: camH * 1.6)

        case .helicopter:
            CGSize(width: camW * 4.5, height: -camH * 1.2)
        case .drone:
            CGSize(width: camW * 4.5, height: -camH)
            
        case .goalLineLHS:
            CGSize(width: -camW * 2, height: camH * 1.7)
        case .goalLineRHS:
            CGSize(width: camW * 2, height: camH * 1.7)
            
        case .spiderCam:
            CGSize(width: 0, height: 0)
            
        case .teamArrivals:
            CGSize(width: camW * 3, height: camH * 1.9)
        case .flashInterview:
            CGSize(width: camW * 3, height: camH)
        case .dressingRoom:
            CGSize(width: camW * 3, height: camH * 1.7)
        case .pressConference:
            CGSize(width: -camW * 3, height: camH * 1.9)
        case .tunnelCam:
            CGSize(width: 0, height: camH * 1.8)
        }
    }
    
    static func == (lhs: Camera, rhs: Camera) -> Bool {
           lhs.position == rhs.position
       }
       func hash(into hasher: inout Hasher) {
           hasher.combine(position)
       }
    
    init(position: CameraPosition){
        self.position = position
    }
}
