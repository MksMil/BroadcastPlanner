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
    case plus = "plus"
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
    
    @MainActor var primaryAction: ()->() = {}
    @MainActor var secondaryAction: ()->() = {}
    @MainActor var stepBackAction: ()->() = {}
    
    // MARK: init
    init(){
        startTimer()
    }
    
    deinit{
        print("appstate deinit")
        stopTimer()
    }
    // MARK: - start app
    let isStartAnimationFinishedPublisher = CurrentValueSubject<Bool,Never>(false)
    func animationFinished(_ finished: Bool = true){
        isStartAnimationFinishedPublisher.value = finished
    }
    
    // MARK: - Title
    
    let titlePublisher = CurrentValueSubject<String, Never>("Hello")
    
    func setTitle(_ newTitle: String){
        if titlePublisher.value != newTitle{
            titlePublisher.value = newTitle
        }
    }
    
    // MARK: - MainNotifications
    let notificationPublisher = CurrentValueSubject<StatusViewNotification,Never>(StatusViewNotification(id: UUID(),
                                                                                                         text: "Hello",
                                                                                                         textColor: Color.primary,
                                                                                                         cycle: .once))
    func addNewNotification(note: StatusViewNotification){
        notificationPublisher.value = note
    }
    
    // MARK: - Timer
    let currentTime:  PassthroughSubject = PassthroughSubject<Date,Never>()
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

    let isPrimaryButtonEnabledPublisher = CurrentValueSubject<Bool,Never>(false)
    let isPrimaryButtonVisiblePublisher = CurrentValueSubject<Bool,Never>(false)
    let primaryIconPublisher = CurrentValueSubject<ButtonIcon,Never>(.accept)
    func makePrimaryButtonEnabled(_ enabled: Bool){
        isPrimaryButtonEnabledPublisher.value = enabled
    }
    func makePrimaryButtonVisible(_ visible: Bool){
        isPrimaryButtonVisiblePublisher.value = visible
    }
    func setIconToPrimaryButton(_ icon: ButtonIcon){
        primaryIconPublisher.value = icon
    }
    
    // MARK: - Secondary action button
   
    let isSecondaryButtonEnabledPublisher = CurrentValueSubject<Bool,Never>(false)
    let isSecondaryButtonVisiblePublisher = CurrentValueSubject<Bool,Never>(false)
    let secondaryIconPublisher = CurrentValueSubject<ButtonIcon,Never>(.cancel)
    func makeSecondaryButtonEnabled(_ enabled: Bool){
        isSecondaryButtonEnabledPublisher.value = enabled
    }
    func makeSecondaryButtonVisible(_ visible: Bool){
        isSecondaryButtonVisiblePublisher.value = visible
    }
    func setIconToSecondaryButton(_ icon: ButtonIcon){
        secondaryIconPublisher.value = icon
    }

    
    // MARK: - Back button

    let isBacwardButtonEnabledPublisher = CurrentValueSubject<Bool,Never>(false)
    let isBackwardButtonVisiblePublisher = CurrentValueSubject<Bool,Never>(false)
    func makeBackwardButtonEnabled(_ enabled: Bool){
        isBacwardButtonEnabledPublisher.value = enabled
    }
    func makeBackwardButtonVisible(_ visible: Bool){
        isBackwardButtonVisiblePublisher.value = visible
    }
    
    // MARK: - Tab and unread messages counter
    
   
    let isMessengerActivePublisher = CurrentValueSubject<Bool, Never>(false)
    let unreadMessagesPublisher = CurrentValueSubject<Int,Never>(0)
    func makeMessengerActive(_ active: Bool){
        isMessengerActivePublisher.value = active
    }
    func setUnreadMessages(num: Int){
        guard num >= 0 else{ return }
        unreadMessagesPublisher.value = num
    }
    // MARK: Menu state  - enables of elements in status menu
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
        isPrimaryButtonEnabledPublisher.value = conf.isPrimaryButtonEnable
        isPrimaryButtonVisiblePublisher.value = conf.isPrimaryButtonVisisble
        primaryIconPublisher.value = conf.primaryButtonIcon
        
        isSecondaryButtonEnabledPublisher.value = conf.isSecondaryButtonEnabled
        isSecondaryButtonVisiblePublisher.value = conf.isSecondaryButtonVisible
        secondaryIconPublisher.value = conf.secondaryButtonIcon
        
        isBacwardButtonEnabledPublisher.value = conf.isBackButtonEnabled
        isBackwardButtonVisiblePublisher.value = conf.isBackButtonVisible
        
        menuState = conf.menuState
        titlePublisher.value = conf.title
    }
    
    // MARK: - NetworkStatus
    private var networkStatus: Bool = false{
        willSet{
            networkStatusPublisher.send(newValue)
        }
    }
    
    let networkStatusPublisher = PassthroughSubject<Bool,Never>()
}

// MARK: - Progress show
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

// MARK: - State configuration
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
    // MARK: static configurations
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
        title: "All Events"
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
    
    static let ClubSheetConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .plus,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .settings,
        title: "Edit Club"
    )
    
    static let AddEditClubConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: false,
        isSecondaryButtonEnabled: false,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .settings,
        title: "Edit Club"
    )
    
    static let AddEditVenueConfiguration: StateCongiguration = StateCongiguration(
        isPrimaryButtonVisisble: true,
        isPrimaryButtonEnable: true,
        primaryButtonIcon: .accept,
        isSecondaryButtonVisible: true,
        isSecondaryButtonEnabled: true,
        secondaryButtonIcon: .remove,
        isBackButtonVisible: true,
        isBackButtonEnabled: true,
        menuState: .settings,
        title: "Edit Venue"
    )
}


