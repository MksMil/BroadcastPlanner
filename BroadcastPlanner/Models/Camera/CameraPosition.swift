import Foundation

enum CameraPosition: String, CaseIterable, Identifiable{
    
    var id: Self { self }
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
    
}
