import Firebase
import GoogleSignIn
import UserNotifications

// MARK: - AppDelegate, Firebase configuration, GID configuration, UserNotification delegate
class AppDelegate: NSObject, UIApplicationDelegate,
  UNUserNotificationCenterDelegate
{

  weak var notificationHandler: NotificationHandler?
  //make a protocol and delegate property to redirect notification data to app
  // define delegate
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication
      .LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Инициализация Firebase
    FirebaseApp.configure()

    // Настройка делегата для центра уведомлений
    UNUserNotificationCenter.current().delegate = self

    // Запрос разрешения на уведомления
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .sound, .badge,
    ]) { granted, error in
      if let error = error {
        print(
          "Ошибка запроса разрешения на уведомления: \(error.localizedDescription)"
        )
        return
      }
      if granted {
        DispatchQueue.main.async {
          // Регистрация для удаленных уведомлений
          application.registerForRemoteNotifications()
        }
      }
    }

    return true
  }
  //google sign in
  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }

  // MARK: - UNUserNotificationCenterDelegate

  // Обработка уведомлений, когда приложение активно
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Показывать уведомления даже в активном состоянии приложения
    completionHandler([ /*.banner,*/.sound, .badge])
  }

  // Обработка действий пользователя с уведомлением (например, нажатие)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("Получено уведомление с данными: \(userInfo)")
    // Здесь можно обработать данные уведомления, например, открыть определенный чат
    notificationHandler?.handleNotification(userInfo: userInfo)
    completionHandler()

  }

  // Обработка успешной регистрации для удаленных уведомлений
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print(
      "APNs-токен получен: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())"
    )
    // Передача токена в Firebase (если используется FCM)
    // Например: Messaging.messaging().apnsToken = deviceToken
  }

  // Обработка ошибки регистрации для уведомлений
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Ошибка регистрации для уведомлений: \(error.localizedDescription)")
  }
}
