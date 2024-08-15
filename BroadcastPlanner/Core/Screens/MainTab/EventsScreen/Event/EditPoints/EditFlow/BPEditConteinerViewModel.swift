import SwiftUI

final class BPEditConteinerViewModel: ObservableObject{
    @Published private var filter: BPEventPlanPointStadiumFilter = .all
    @Published private var selectrdPoint: BPEventPlanPoint?
    
    weak var renderDelegete: BPPlanDelegateProtocol?
    
    
}
