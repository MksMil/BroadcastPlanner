import Foundation

//globals settings for UI and all standart cases (images, eventLocations, etc.)can be fetched from network

class GlobalSettings: ObservableObject {
    var eventLocations: [EventLocation]
    var planPointsTemlates: [BPEventPlan] = []
    
    
    //locationId: [imageName]
    var staiumImages: [String: [String]]
    var broadcasters: [Broadcaster] = []
    var carImages: [String]
    //crete location
    //edit location
    //fetch locations
    
    // MARK: - Initialization
    init(eventLocations: [EventLocation] = [],
         stadiumImages: [String: [String]] = [:],
         carImages: [String] = []) {
        self.eventLocations = eventLocations
        self.staiumImages = stadiumImages
        self.carImages = carImages
    
        self.fetchData()
    }
    
    // MARK: - load data
    func fetchData(){
        //load mock
        self.eventLocations = MockData.sampleLocations
    }
}
