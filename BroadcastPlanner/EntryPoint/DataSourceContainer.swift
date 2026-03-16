// MARK: - DataSource factory
import Combine

@MainActor
final class DataSourceContainer: ObservableObject {
  let networkManager: NetworkManager
  let dataManager: DataManager

  init() {
    let nm = NetworkManager()
    self.networkManager = nm
    do {
      self.dataManager = try DataManager(networkManager: nm)
    } catch {
      fatalError("DataSourceContainer: failed to initialize — \(error)")
    }
  }

  func configure(
    appState: ApplicationState,
    globalSettings: GlobalSettings,
    notificationHandler: NotificationHandler
  ) {
    networkManager.eventProgressHandler = appState
    networkManager.globalSettings.delegate = globalSettings
  }
}
