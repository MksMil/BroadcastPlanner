import SwiftUI
import Combine

final class LocationSelectionViewModel: ObservableObject{
    var location: Venue?
    
    @Published var isLocationSheetPresented: Bool = false
    @Published var title: String
    @Published var address: String
    
    var imageIds: [String] = []
    var maxCount: Int { imageIds.count}
    
    @Published var imageId: String = ""
    @Published var counter: Int = 0
    
    let timer = Timer.publish(every: 8, on: .main, in: .common)
    var timerCancellable: Cancellable?
    private var cancellables: Set<AnyCancellable> = []
    
    init(location: Venue?){
        self.title = location?.viewTitle ?? ""
        self.address = location?.viewAddress ?? ""
        self.location = location
//        self.imageIds = location?.viewImageIds ?? []
        updateImageIds(newImageIds: location?.viewImageIds ?? [])
    }
    deinit{
        stop()
    }
    
    
    func start(){
        counter = 0
        configurePublisher()
        timerCancellable = timer.connect()
    }
    
    func stop(){
        counter = 0
        timerCancellable?.cancel()
        cancellables.forEach({$0.cancel()})
        cancellables.removeAll()
    }
    
    func configurePublisher() {
        timer
            .sink { [weak self] _ in
                guard let self, self.maxCount != 0 else { return }
                self.updateCounter()
                self.imageId = self.imageIds[counter]
            }
            .store(in: &cancellables)
    }
    
    func updateCounter(){
        (counter < maxCount - 1) ? (counter += 1):(counter = 0)
    }
    
    func updateImageIds(newImageIds: [String]){
        stop()
        imageIds = newImageIds
        counter = 0
        if imageIds.isEmpty{
            imageIds = []
        }
//        self.imageId = imageIds[counter]
        if imageIds.count > 1 { start() }
    }
    
    @MainActor
    func update(newLocation: Venue){
        self.location = newLocation
        title = newLocation.viewTitle
        address = newLocation.viewAddress
        updateImageIds(newImageIds: newLocation.viewImageIds)
    }
}
