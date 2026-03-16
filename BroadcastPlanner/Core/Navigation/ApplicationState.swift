import SwiftUI
import Combine
import UserNotifications

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
    case obvan = "truck.box"
}

enum MenuState: String {
    case info
    case settings
    case none
}
// Тип поля для контекстно-зависимых кнопок
enum TextFieldType: Equatable {
    case login
    case password
    case email
    case phone
    case custom([String]) // Для кастомных символов

    var toolbarButtons: [String] {
        switch self {
        case .login:
            return ["@"]
        case .password:
            return ["#", "!"]
        case .email:
            return ["@", "."]
        case .custom(let symbols):
            return symbols
            default:
                return []
        }
    }
    var contentType: UITextContentType? {
        switch self {
            case .login:
                    .username
            case .password:
                    .password
            case .email:
                    .emailAddress
            case .phone:
                    .telephoneNumber
            default:
                    nil
        }
    }
    var keyboardType: UIKeyboardType{
        switch self {
            case .login:
                    .alphabet
            case .password:
                    .default
            case .email:
                    .emailAddress
            case .phone:
                    .numbersAndPunctuation
            case .custom( _):
                    .alphabet
            @unknown default:
                    .alphabet
        }
    }
}

protocol NotificationHandler: AnyObject {
  func handleNotification(userInfo: [AnyHashable: Any])
}

class ApplicationState: ObservableObject{
    @Published var state: AppState = .notAuthorized
    @Published var userOnlineStatus: UserOnlineStatus = .offline
    
    @MainActor var primaryAction: ()->() = {}
    @MainActor var secondaryAction: ()->() = {}
    @MainActor var stepBackAction: ()->() = {}
    
    // MARK: - GlobalTextField Control
    @Published var fieldType: TextFieldType = .custom([])
    @Published var textfieldSource: String = ""
    @Published var isTextFieldShowed: Bool = false
    var isSecure: Bool = false
    var promptString: String = "Enter your information here!"
    var doneAction: (String)->() = { _ in  }
    func openTextFieldWithAction(_ action: @escaping (String)->()){
        doneAction = action
        isTextFieldShowed = true
        
    }
    func closeTextField(){
        isTextFieldShowed = false
        cleanTFInfo()
    }
    func cleanTFInfo(){
        textfieldSource = ""
        isSecure = false
        doneAction = {_ in }
    }
    
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
    
    let titlePublisher = CurrentValueSubject<String, Never>("")
    
    func setTitle(_ newTitle: String){
        if titlePublisher.value != newTitle{
            titlePublisher.value = newTitle
        }
    }
    
    // MARK: - MainNotifications
    let notificationPublisher = CurrentValueSubject<StatusViewNotification,Never>(StatusViewNotification(id: UUID(), text: "Hello",textColor: Color.primary,cycle: .once))
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
    var menuStatePublisher = CurrentValueSubject<MenuState,Never>(.none)
    func setMenuState(state: MenuState){
        menuStatePublisher.value = state
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
        
        menuStatePublisher.value = conf.menuState
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

// MARK: - Path handler
//extension ApplicationState{
//    func switchStateByPath(_ path: RouterPath){
//        switch path {
//            case .animatedStart:
//                applyAppConfiguration(StateCongiguration.AllDissabledConfiguration)
////            case .authScreen:
////                <#code#>
//            case .broadcastList:
//                applyAppConfiguration(StateCongiguration.MainListConfiguration)
//            case .createEdit(_):
//                applyAppConfiguration(StateCongiguration.BroadcastEditViewConfiguration)
//            case .stadPointsEdit(_):
//                applyAppConfiguration(StateCongiguration.StadPointsEditViewConfiguration)
//            case .ownerInfo:
//                applyAppConfiguration(StateCongiguration.OwnerInfoConfiguration)
////            case .memberView:
////                <#code#>
//            case .settings:
//                applyAppConfiguration(StateCongiguration.SettingsConfiguration)
//            case .updateSessionUserData:
//                applyAppConfiguration(StateCongiguration.UpdateSessionUserDataConfiguration)
//            case .clubCollection:
//                applyAppConfiguration(StateCongiguration.ClubCollectionConfiguration)
//            case .addEditClub(_):
//                applyAppConfiguration(StateCongiguration.AddEditClubConfiguration)
//
//            case .obvanCollection:
//                applyAppConfiguration(StateCongiguration.ObvanCollectionConfiguration)
//            case .addEditObvan(_):
//                applyAppConfiguration(StateCongiguration.AddEditObvanConfiguration)
//                
//            case .venueCollection:
//                applyAppConfiguration(StateCongiguration.VenueCollectionConfiguration)
//            case .addEditVenue(_):
//                applyAppConfiguration(StateCongiguration.AddEditVenueConfiguration)
//                
//            case .messenger:
//                applyAppConfiguration(StateCongiguration.MessengerConfiguration)
//            default: applyAppConfiguration(StateCongiguration.AllDissabledConfiguration)
//        }
//    }
//}

// MARK: - NotificationHandler
extension ApplicationState: NotificationHandler {
    func handleNotification(userInfo: [AnyHashable: Any]) {
      // TODO: реализовать после определения структуры userInfo с бэкенда
              // 1. Парсить тип уведомления (userInfo["type"])
              // 2. Формировать текст для бегущей строки
              // 3. Вызвать addNewNotification()
      
        // Извлекаем текст из aps
      /*
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: Any]
        let title = alert?["title"] as? String ?? ""
        let body = alert?["body"] as? String ?? ""
        let text = [title, body].filter { !$0.isEmpty }.joined(separator: ": ")
        
        // Отправляем в бегущую строку
        DispatchQueue.main.async {
            self.addNewNotification(note: StatusViewNotification(
                id: UUID(),
                text: text,
                textColor: .primary,
                cycle: .once
            ))
        }
       */
    }
}




