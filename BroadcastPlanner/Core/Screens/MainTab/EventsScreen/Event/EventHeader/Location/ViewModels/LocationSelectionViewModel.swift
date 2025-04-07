import SwiftUI
import Combine

final class LocationSelectionViewModel: ObservableObject{
    var location: LocalLocation?
    
    @Published var isLocationSheetPresented: Bool = false
    @Published var title: String
    @Published var address: String
    
    var images: [Image] = []
    var maxCount: Int { images.count}
    
    @Published var image: Image = Image("neitral")
    @Published var counter: Int = 0
    
    let timer = Timer.publish(every: 8, on: .main, in: .common)
    var timerCancellable: Cancellable?
    private var cancellables: Set<AnyCancellable> = []
    
    init(location: LocalLocation?){
        self.title = location?.viewTitle ?? ""
        self.address = location?.viewAddress ?? ""
        self.location = location
        self.images = location?.viewImages ?? []
        updateImages(newImages: images)
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
                self.image = self.images[counter]
            }
            .store(in: &cancellables)
    }
    
    func updateCounter(){
        (counter < maxCount - 1) ? (counter += 1):(counter = 0)
    }
    
    func updateImages(newImages: [Image]){
        stop()
        images = newImages
        counter = 0
        if images.isEmpty{
            images = [Image("neitral")]
        }
        self.image = images[counter]
        if images.count > 1 { start() }
    }
    
    @MainActor
    func update(newLocation: LocalLocation ){
        self.location = newLocation
        title = newLocation.viewTitle
        address = newLocation.viewAddress
        updateImages(newImages: newLocation.viewImages)
    }
}
