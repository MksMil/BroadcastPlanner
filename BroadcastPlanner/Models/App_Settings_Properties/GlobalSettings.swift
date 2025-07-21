import Foundation

//globals settings for UI and all pointlocation and crew templates

class GlobalSettings: ObservableObject,Codable {
    
    //MARK: - Member
    var userSpecialization: [String] = [
        
        "Producer",
        "Floor manager",
        
        "Main director",
        "Director",
        
        "Main cameramen",
        "Cameramen",
        
        "Replay director",
        "Replay operator",
        
        "Main sound director",
        "Sound director",
        
        "Graphics operator",
        "Unknown"
    ]
    
    //MARK: - Camera
    //MARK: Position
    var cameraPosition: [String] = [
        "Unknown",
        "Main Match Camera Wide Angle",
        "Main Close Up",
        
        //central pitch
        "Pitch Central Ring",
        
        //left goal
        "Left Behind Goal",

        //right goal
        "Right Behind Goal",

        //reverce
        "Reverse Central lower tier",

        //high behindGoal RHS
        "Right High behind goal",
        
        //offsides
        "left offside",
        "right offside",
        
        ///Extended cams
        //left hand side cameras
       "Left Behind Goal Mirror",
        "Left PoleCam",
         "Goal LHS left",
         "Goal LHS right",
         "Left High behind goal",
        
        //right hand side cameras
        "Right Behind Goal Mirror",
        "Right PoleCam",
        "Goal RHS left",
        "Goal RHS right",
        
        //reverses
         "Reverse Central upper tier",
        "Second Reverse Central upper tier",
        "Second Reverse Central lower tier",
        
        "left pitch",
        "right pitch",
        
        //stedicams
        "Stedicam Left Side",
        "Stedicam Right Side",
        "Reverse stedicam Left Side",
        "Reverse stedicam Right Side",

        //beauty shots
        "Upper left Beauty Shot",
        "Upper right Beauty Shot",
        "Lower left Beauty Shot",
        "Lower right Beauty Shot",
        "Helicopter",
        "Drone",
        
        //goal line cam
        "Left goal line",
        "Right goal line",
        
        //spider cam
        "Spider cam",
        
        //support
        "Team arrivals",
        "Flash interview",
        "Dressing room",
        "Press conference",
        "Tunell cam"
    ]
    //MARK: Optic
    var opticType: [String] = [
        "Empty",
        "x14",
        "x22",
        "x40",
        "x60",
        "x75",
        "x76",
        "x86",
        "x95",
         "pole cam",
          "spider",
         "drone",
         "helicopter",
         "Black Hawk",
        "Archer 2",
        "Unknown"
    ]
    
    
    //MARK: - Sound
    var soundPlaceType: [String] = [
        "Empty",
        "On Camera",
        "Low Tripod",
         "Super Low Tripod",
         "High Tripod",
         "Super High Tripod",
        "Unknown"
    ]
    
    var windDefenceType: [String] = [
        "Empty",
        "Dog",
        "Unknown"
    ]
    
    //MARK: - Light
    var lightType: [String] = [
        "Empty",
        "Unknown",
    ]
    
    //MARK: - Hardware
    var hardwareType: [String] = [
        "Empty",
        "EVS",
        "K2-DYNO",
        "BLT",
        "SLOMO",
        "V-MIX",
        "Unknown"
    ]
    // MARK: - Initialization
    init() {
        
    }
    
    
    
}
