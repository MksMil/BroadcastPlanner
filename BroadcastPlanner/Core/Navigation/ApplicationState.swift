import SwiftUI
import Combine

enum AppState {
    case authorized, notAuthorized
}

enum UserOnlineStatus {
    case online, offline
}

enum ButtonIcon: String{
    case accept = "checkmark"
    case remove = "trash"
    case edit = "pencil"
    case cancel = "xmark"
}

enum MenuState: String {
    case info
    case settings
    case none
}

class ApplicationState: ObservableObject{
    @Published var state: AppState = .notAuthorized
    @Published var userOnlineStatus: UserOnlineStatus = .offline
    
    var primaryAction: ()->() = {}
    var secondaryAction: ()->() = {}
    var stepBackAction: ()->() = {}
    
    init(){
        startTimer()
    }
    
    // MARK: - Timer
    var currentTime:  PassthroughSubject = PassthroughSubject<Date,Never>()
    var timer: Cancellable?
    
    func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentTime.send(.now)
            }
    }
    func stopTimer(){
        timer?.cancel()
    }
    
    //MARK: - actionView controls
    var isPrimaryButtonEnable: Bool = false {
        willSet{
            isPrimaryButtonEnabledPublisher.send(newValue)
        }
    }
    var isPrimaryButtonVisible: Bool = false {
        willSet{
            isPrimaryButtonVisiblePublisher.send(newValue)
        }
    }
    var primaryIcon: ButtonIcon = .accept {
        willSet{
            primaryIconPublisher.send(newValue)
        }
    }
    var secondaryIcon: ButtonIcon = .remove {
        willSet{
            secondaryIconPublisher.send(newValue)
        }
    }
    var isSecondaryButtonEnabled: Bool = false {
        willSet{
            isSecondaryButtonEnabledPublisher.send(newValue)
        }
    }
    var isSecondaryButtonVisible: Bool = false {
        willSet{
            isSecondaryButtonVisiblePublisher.send(newValue)
        }
    }
    
    var isBackwardButtonVisible: Bool = false {
        willSet{
            isBackwardButtonVisiblePublisher.send(newValue)
        }
    }
    var isBackwardButtonEnabled: Bool = false{
        willSet{
            isBacwardButtonEnabledPublisher.send(newValue)
        }
    }
    var isMessangerActive: Bool = false {
        willSet{
            isMessengerActivePublisher.send(newValue)
        }
    }
    var unreadMessages: Int = 0 {
        willSet{
            unreadMessagesPublisher.send(newValue)
        }
    }
    
    var primaryIconPublisher = PassthroughSubject<ButtonIcon,Never>()
    var secondaryIconPublisher = PassthroughSubject<ButtonIcon,Never>()
    
    var isPrimaryButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    var isSecondaryButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    var isBacwardButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    
    var isPrimaryButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    var isSecondaryButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    var isBackwardButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    
    var isMessengerActivePublisher = PassthroughSubject<Bool,Never>()
    var unreadMessagesPublisher = PassthroughSubject<Int,Never>()
   
    
    var menuState: MenuState = .none
    
    
    //main
    func setAppUIState(isBackwardEnabled: Bool = false,
                       isBackwardVisible: Bool = false,
                       isPrimaryEnabled: Bool = false,
                       isPrimaryVisible: Bool = false,
                       primaryIcon: ButtonIcon = .accept,
                       isSecondaryEnabled: Bool = false,
                       isSecondaryVisible: Bool = false,
                       secondaryIcon: ButtonIcon = .remove){
        
        makeBackwardButtonVisible(isBackwardVisible)
        makePrimaryButtonVisible(isPrimaryVisible)
        makeSecondaryButtonVisible(isSecondaryVisible)

        makeBackwardButtonEnabled(isBackwardEnabled)
        makePrimaryButtonEnabled(isPrimaryEnabled)
        makeSecondaryButtonEnabled(isSecondaryEnabled)
        
        setIconToPrimaryButton(primaryIcon)
        setIconToSecondaryButton(secondaryIcon)
    }
    
    @MainActor
    func setDefaultUIState(){
        
        setAppUIState(isBackwardEnabled: false,
                      isBackwardVisible: false,
                      isPrimaryEnabled: false,
                      isPrimaryVisible: false,
                      primaryIcon: .accept,
                      isSecondaryEnabled: false,
                      isSecondaryVisible: false,
                      secondaryIcon: .remove)
        
        menuState = .none
    }
    
    
    //helper
    func setMenuState(state: MenuState){
        menuState = state
    }
    
    func makePrimaryButtonEnabled(_ enabled: Bool){
        isPrimaryButtonEnable = enabled
    }
    func makeSecondaryButtonEnabled(_ enabled: Bool){
        isSecondaryButtonEnabled = enabled
    }
    func makeBackwardButtonEnabled(_ enabled: Bool){
        isBackwardButtonEnabled = enabled
    }
    func makePrimaryButtonVisible(_ visible: Bool){
        isPrimaryButtonVisible = visible
    }
    func makeSecondaryButtonVisible(_ visible: Bool){
        isSecondaryButtonVisible = visible
    }
    func makeBackwardButtonVisible(_ visible: Bool){
        isBackwardButtonVisible = visible
    }
    func makeMessengerActive(_ active: Bool){
        isMessangerActive = active
    }
    
    func setUnreadMessages(num: Int){
        guard num >= 0 else{ return }
        unreadMessages = num
    }
    
    func setIconToPrimaryButton(_ icon: ButtonIcon){
        primaryIcon = icon
    }
    func setIconToSecondaryButton(_ icon: ButtonIcon){
        secondaryIcon = icon
    }
    
}
