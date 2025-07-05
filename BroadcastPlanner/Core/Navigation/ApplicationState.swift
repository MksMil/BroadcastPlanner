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
    
    // MARK: init
    init(){
        startTimer()
    }
    
    deinit{
        print("appstate deinit")
        stopTimer()
    }
    // MARK: - start app
    var isStartAnimationFinished: Bool = false {
        willSet{
            startPublisher.send(newValue)
        }
    }
    
    let startPublisher = PassthroughSubject<Bool,Never>()
    
    // MARK: - Title
    var title: String = "Hello" {
        willSet{
            titlePublisher.send(newValue)
        }
    }
    let titlePublisher = PassthroughSubject<String, Never>()
    
    func setTitle(_ newTitle: String){
        if title != newTitle{
            title = newTitle
        }
    }
    
    // MARK: - MainNotifications
    let notificationPublisher = PassthroughSubject<StatusViewNotification,Never>()
    func addNewNotification(note: StatusViewNotification){
        notificationPublisher.send(note)
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
    
    //MARK: - Primary action button
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
    let isPrimaryButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    let isPrimaryButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    let primaryIconPublisher = PassthroughSubject<ButtonIcon,Never>()
    func makePrimaryButtonEnabled(_ enabled: Bool){
        isPrimaryButtonEnable = enabled
    }
    func makePrimaryButtonVisible(_ visible: Bool){
        isPrimaryButtonVisible = visible
    }
    func setIconToPrimaryButton(_ icon: ButtonIcon){
        primaryIcon = icon
    }
    
    // MARK: - Secondary action button
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
    var isSecondaryButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    var isSecondaryButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    var secondaryIconPublisher = PassthroughSubject<ButtonIcon,Never>()
    func makeSecondaryButtonEnabled(_ enabled: Bool){
        isSecondaryButtonEnabled = enabled
    }
    func makeSecondaryButtonVisible(_ visible: Bool){
        isSecondaryButtonVisible = visible
    }
    func setIconToSecondaryButton(_ icon: ButtonIcon){
        secondaryIcon = icon
    }

    
    // MARK: - Back button
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
    var isBacwardButtonEnabledPublisher = PassthroughSubject<Bool,Never>()
    var isBackwardButtonVisiblePublisher = PassthroughSubject<Bool,Never>()
    func makeBackwardButtonEnabled(_ enabled: Bool){
        isBackwardButtonEnabled = enabled
    }
    func makeBackwardButtonVisible(_ visible: Bool){
        isBackwardButtonVisible = visible
    }
    
    // MARK: - Tab and unread messages counter
    var unreadMessages: Int = 0 {
        willSet{
            unreadMessagesPublisher.send(newValue)
        }
    }
    var isMessangerActive: Bool = false {
        willSet{
            isMessengerActivePublisher.send(newValue)
        }
    }
    var isMessengerActivePublisher = PassthroughSubject<Bool,Never>()
    var unreadMessagesPublisher = PassthroughSubject<Int,Never>()
    func makeMessengerActive(_ active: Bool){
        isMessangerActive = active
    }
    func setUnreadMessages(num: Int){
        guard num >= 0 else{ return }
        unreadMessages = num
    }
    // MARK: Menu state
    var menuState: MenuState = .none
    func setMenuState(state: MenuState){
        menuState = state
    }

    //main
    func setAppUIState(isBackwardEnabled: Bool = false,
                       isBackwardVisible: Bool = false,
                       isPrimaryEnabled: Bool = false,
                       isPrimaryVisible: Bool = false,
                       primaryIcon: ButtonIcon = .accept,
                       isSecondaryEnabled: Bool = false,
                       isSecondaryVisible: Bool = false,
                       secondaryIcon: ButtonIcon = .remove){
        
        makePrimaryButtonEnabled(isPrimaryEnabled)
        makePrimaryButtonVisible(isPrimaryVisible)
        setIconToPrimaryButton(primaryIcon)

        makeSecondaryButtonEnabled(isSecondaryEnabled)
        makeSecondaryButtonVisible(isSecondaryVisible)
        setIconToSecondaryButton(secondaryIcon)
        
        makeBackwardButtonEnabled(isBackwardEnabled)
        makeBackwardButtonVisible(isBackwardVisible)
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
    
    func applyAppConfiguration(_ conf: StateCongiguration){
        isPrimaryButtonEnable = conf.isPrimaryButtonEnable
        isPrimaryButtonVisible = conf.isPrimaryButtonVisisble
        primaryIcon = conf.primaryButtonIcon
        
        isSecondaryButtonEnabled = conf.isSecondaryButtonEnabled
        isSecondaryButtonVisible = conf.isSecondaryButtonVisible
        secondaryIcon = conf.secondaryButtonIcon
        
        isBackwardButtonEnabled = conf.isBackButtonEnabled
        isBackwardButtonVisible = conf.isBackButtonVisible
        
        menuState = conf.menuState
        title = conf.title
    }
    
    // MARK: - NetworkStatus
    private var networkStatus: Bool = false{
        willSet{
            networkStatusPublisher.send(newValue)
        }
    }
    
    let networkStatusPublisher = PassthroughSubject<Bool,Never>()
}

protocol EventsProgressHandler: AnyObject{
    func startLoading()
    func stopLoading()
    func updateNetworkStatus(isOnline: Bool)
}

extension ApplicationState: EventsProgressHandler{
    func startLoading() {
        
    }
    
    func stopLoading() {
        
    }
    func updateNetworkStatus(isOnline: Bool){
        networkStatus = isOnline
    }
    
}

struct StateCongiguration {
    //primary button
    let isPrimaryButtonVisisble: Bool
    let isPrimaryButtonEnable: Bool
    let primaryButtonIcon: ButtonIcon
    //secondaru button
    let isSecondaryButtonVisible: Bool
    let isSecondaryButtonEnabled: Bool
    let secondaryButtonIcon: ButtonIcon
    //back button
    let isBackButtonVisible: Bool
    let isBackButtonEnabled: Bool
    //menu state
    let menuState: MenuState
    //title
    let title: String
    
    static let MainListConfiguration : StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: false,
        isBackButtonEnabled: false,
        menuState: .none,
        title: "Broadcasts list"
    )
    static let OwnerInfoConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .edit,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .info,
        title: "My Info"
    )
    
    static let SettingsConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: false,
        isPrimaryButtonEnable: false,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .settings,
        title: "Settings"
    )
    static let BroadcastEditViewConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: true,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Edit Broadcast"
    )
    
    static let StadPointsEditViewConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: true,
        secondaryButtonIcon: .cancel,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .none,
        title: "Edit schema"
    )
}


