import Foundation
import Combine

final class GlobalTimer: ObservableObject{
    
    //timer publisher
    
    @Published var timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()
}
