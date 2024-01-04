import Foundation

final class Camera: Identifiable, ObservableObject {
    var id = UUID()
    
    @Published var cameraMan: User = User()
    @Published var selected: Bool = false
    @Published var number: String = ""
    @Published var position: CameraPosition
    
    //init
    init(position: CameraPosition){
        self.position = position
    }
    
    //
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
   
}

extension Camera: Hashable, Equatable{
    static func == (lhs: Camera, rhs: Camera) -> Bool {
        lhs.position == rhs.position
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
}
