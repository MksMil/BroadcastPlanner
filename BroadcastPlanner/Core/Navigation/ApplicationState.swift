import SwiftUI
import Combine
import UserNotifications
import Foundation

enum AppState {
  case authorized, notAuthorized
}

enum UserOnlineStatus {
  case online, offline
}

protocol NotificationHandler: AnyObject {
  func handleNotification(userInfo: [AnyHashable: Any])
}

class ApplicationState: ObservableObject{
  
  var user: MemberDTO = MemberDTO()
  
  @Published var userOnlineStatus: UserOnlineStatus = .offline
  var state: AppState = .notAuthorized {
    didSet {
      userOnlineStatus = state == .authorized ? .online: .offline
    }
  }
  weak var router: Router?
  var isSecure: Bool = false
  var backAction: ()->Void = {} 
  // MARK: init
  init(){
    startTimer()
  }
  
  deinit{
    print("appstate deinit")
    stopTimer()
  }
  
  @MainActor
  func setRouter(router: Router){
    self.router = router
    setDefaultBackAction()
  }
  @MainActor
  func setDefaultBackAction(){
    if let router {
      backAction = router.stepBack
    }
  }
  // MARK: - Timer
  let currentTime:  PassthroughSubject = PassthroughSubject<Date,Never>()
  var timer: Cancellable?
  
  func startTimer() {
    timer = Timer.publish(every: 1.0, on: .main, in: .common)
      .autoconnect()
      .sink { _ in
        self.currentTime.send(.now)
      }
  }
  func stopTimer(){
    timer?.cancel()
  }
  
  // MARK: - Title
  
  let titlePublisher = CurrentValueSubject<String, Never>("Приветствую!")
  
  func setTitle(_ newTitle: StatusViewTitleCase){
    var resultString: String
    switch newTitle {
      case .notFiltered:
        resultString = newTitle.rawValue
      case .userOwned:
        resultString = newTitle.rawValue
      case .userParticipation:
        resultString = newTitle.rawValue
      case .base:
        resultString = newTitle.rawValue + " \(user.firstName)"
    }
        if titlePublisher.value != resultString{
      titlePublisher.value = resultString
    }
  }
  
  // MARK: - MainNotifications
  let notificationPublisher = CurrentValueSubject<StatusViewNotification,Never>(StatusViewNotification(id: UUID(), text: "Hello",textColor: Color.primary,cycle: .once))
  func addNewNotification(note: StatusViewNotification){
    notificationPublisher.value = note
  }
  
  
}

// MARK: - Progress show
protocol EventsProgressHandler: AnyObject{
  func startLoading()
  func stopLoading()
  func updateNetworkStatus(isOnline: Bool)
}

extension ApplicationState: EventsProgressHandler{
  func updateNetworkStatus(isOnline: Bool) {
    
  }
  
  func startLoading() {
    
  }
  
  func stopLoading() {
    
  }
}


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




