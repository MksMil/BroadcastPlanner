import Combine
import SwiftUI

@MainActor
final class HeaderBackgroundTimelineViewModel: ObservableObject {
    var images: [Image] = []
    var maxCount: Int { images.count}
    
    @Published var image: Image = Image("neitral")
    @Published var counter: Int = 0
    
    let timer = Timer.publish(every: 2, on: .main, in: .common)
    var timerCancellable: Cancellable?

    private var cancellables: Set<AnyCancellable> = []

    init(){
        print("vm init")
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
        print("in update images block \(images)")
        
        stop()
        images = newImages
        counter = 0
        if images.isEmpty{
            images = [Image("neitral")]
        }
        self.image = images[counter]
        if images.count > 1 { start() }
    }
}
