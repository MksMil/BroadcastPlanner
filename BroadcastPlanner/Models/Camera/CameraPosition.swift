import Foundation

enum CameraPosition: String, CaseIterable, Identifiable{
    
    static func positionWithNum(num: Int) -> CameraPosition {
        switch num {
        case 1 : return CameraPosition.mainMatch
//        case 2 : "Main Close Up"
//        
//        //central pitch
//        case 3 : "Pitch Central Ring"
//        
//        //left goal
//        case 4 : "Left Behind Goal"
//
//        //right goal
//        case 5 : "Right Behind Goal"
//
//        //reverce
//        case 6 : "Reverse Central lower tier"
//
//        //high behindGoal RHS
//        case highBehindGoalRHS = "Right High behind goal"
//        
//        //offsides
//        case high16mLHS = "left offside"
//        case high16mRHS = "right offside"
//        
//        ///Extended cams
//        //left hand side cameras
//        case pitchSideBehindGoalLHSMirror = "Left Behind Goal Mirror"
//        case polecamLHS = "Left PoleCam"
//        case goalCamLHSLeftCorner = "Goal LHS left"
//        case goalCamLHSRightCorner = "Goal LHS right"
//        case highBehindGoalLHS = "Left High behind goal"
//        
//        //right hand side cameras
//        case pitchSideBehindGoalRHSMirror = "Right Behind Goal Mirror"
//        case polecamRHS = "Right PoleCam"
//        case goalCamRHSLeftCorner = "Goal RHS left"
//        case goalCamRHSRightCorner = "Goal RHS right"
//        
//        //reverses
//        case reverseCentralUpper = "Reverse Central upper tier"
//        case secondReverseCentralUpper = "Second Reverse Central upper tier"
//        case secondReverseCentralLower = "Second Reverse Central lower tier"
//        
//        case low16mLHS = "left pitch"
//        case low16mRHS = "right pitch"
//        
//        //stedicams
//        case stedicamLHS = "Stedicam Left Side"
//        case stedicamRHS = "Stedicam Right Side"
//        case reverseStedicamLHS = "Reverse stedicam Left Side"
//        case reverseStedicamRHS = "Reverse stedicam Right Side"
//
//        //beauty shots
//        case upperLeftBS = "Upper left Beauty Shot"
//        case upperRightBS = "Upper right Beauty Shot"
//        case lowerLeftBS = "Lower left Beauty Shot"
//        case lowerRightBS = "Lower right Beauty Shot"
//        case helicopter = "Helicopter"
//        case drone = "Drone"
//        
//        //goal line cam
//        case goalLineLHS = "Left goal line"
//        case goalLineRHS = "Right goal line"
//        
//        //spider cam
//        case spiderCam = "Spider cam"
//        
//        //support
//        case teamArrivals = "Team arrivals"
//        case flashInterview = "Flash interview"
//        case dressingRoom = "Dressing room"
//        case pressConference = "Press conference"
//        case tunnelCam = "Tunell cam"
        default:
           return CameraPosition.mainMatch
        }
    }
    
    // MARK: - ID
    var id: Self { self }
    
    // MARK: - Cases
    ///Usial cams
    //main upper
    case mainMatch = "Main Match Camera Wide Angle"
    case mainCloseUp = "Main Close Up"
    
    //central pitch
    case pitchSideHalfWay = "Pitch Central Ring"
    
    //left goal
    case pitchSideBehindGoalLHS = "Left Behind Goal"

    //right goal
    case pitchSideBehindGoalRHS = "Right Behind Goal"

    //reverce
    case reverseCentralLower = "Reverse Central lower tier"

    //high behindGoal RHS
    case highBehindGoalRHS = "Right High behind goal"
    
    //offsides
    case high16mLHS = "left offside"
    case high16mRHS = "right offside"
    
    ///Extended cams
    //left hand side cameras
    case pitchSideBehindGoalLHSMirror = "Left Behind Goal Mirror"
    case polecamLHS = "Left PoleCam"
    case goalCamLHSLeftCorner = "Goal LHS left"
    case goalCamLHSRightCorner = "Goal LHS right"
    case highBehindGoalLHS = "Left High behind goal"
    
    //right hand side cameras
    case pitchSideBehindGoalRHSMirror = "Right Behind Goal Mirror"
    case polecamRHS = "Right PoleCam"
    case goalCamRHSLeftCorner = "Goal RHS left"
    case goalCamRHSRightCorner = "Goal RHS right"
    
    //reverses
    case reverseCentralUpper = "Reverse Central upper tier"
    case secondReverseCentralUpper = "Second Reverse Central upper tier"
    case secondReverseCentralLower = "Second Reverse Central lower tier"
    
    case low16mLHS = "left pitch"
    case low16mRHS = "right pitch"
    
    //stedicams
    case stedicamLHS = "Stedicam Left Side"
    case stedicamRHS = "Stedicam Right Side"
    case reverseStedicamLHS = "Reverse stedicam Left Side"
    case reverseStedicamRHS = "Reverse stedicam Right Side"

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

//    var image: String {
//        switch self {
//        case .mainMatch:
//            <#code#>
//        case .mainCloseUp:
//            <#code#>
//        case .pitchSideHalfWay:
//            <#code#>
//        case .pitchSideBehindGoalLHS:
//            <#code#>
//        case .pitchSideBehindGoalRHS:
//            <#code#>
//        case .reverseCentralLower:
//            <#code#>
//        case .highBehindGoalRHS:
//            <#code#>
//        case .high16mLHS:
//            <#code#>
//        case .high16mRHS:
//            <#code#>
//        case .pitchSideBehindGoalLHSMirror:
//            <#code#>
//        case .polecamLHS:
//            <#code#>
//        case .goalCamLHSLeftCorner:
//            <#code#>
//        case .goalCamLHSRightCorner:
//            <#code#>
//        case .highBehindGoalLHS:
//            <#code#>
//        case .pitchSideBehindGoalRHSMirror:
//            <#code#>
//        case .polecamRHS:
//            <#code#>
//        case .goalCamRHSLeftCorner:
//            <#code#>
//        case .goalCamRHSRightCorner:
//            <#code#>
//        case .reverseCentralUpper:
//            <#code#>
//        case .secondReverseCentralUpper:
//            <#code#>
//        case .secondReverseCentralLower:
//            <#code#>
//        case .low16mLHS:
//            <#code#>
//        case .low16mRHS:
//            <#code#>
//        case .stedicamLHS:
//            <#code#>
//        case .stedicamRHS:
//            <#code#>
//        case .reverseStedicamLHS:
//            <#code#>
//        case .reverseStedicamRHS:
//            <#code#>
//        case .upperLeftBS:
//            <#code#>
//        case .upperRightBS:
//            <#code#>
//        case .lowerLeftBS:
//            <#code#>
//        case .lowerRightBS:
//            <#code#>
//        case .helicopter:
//            <#code#>
//        case .drone:
//            <#code#>
//        case .goalLineLHS:
//            <#code#>
//        case .goalLineRHS:
//            <#code#>
//        case .spiderCam:
//            <#code#>
//        case .teamArrivals:
//            <#code#>
//        case .flashInterview:
//            <#code#>
//        case .dressingRoom:
//            <#code#>
//        case .pressConference:
//            <#code#>
//        case .tunnelCam:
//            <#code#>
//        }
//    }
    
}
