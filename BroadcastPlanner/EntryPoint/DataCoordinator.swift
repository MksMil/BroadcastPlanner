// MARK: - DataSource factory
import Combine

@MainActor
final class DataCoordinator: ObservableObject {
  let networkManager: NetworkManager //nw
  let dataManager: DataManager //cache

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
/*
--------------Все манипуляции с данными:
-- создать/удалить/обновтиь user
   -- change status - online / offline

 -- создать/удалить/обновтиь broadcast
    -- создать/удалить/обновтиь template
    -- создать/удалить/обновтиь venuePoint
    -- создать/удалить/обновтиь cam / mic / light
 
 -- создать/удалить/обновтиь club

 -- создать/удалить/обновтиь obvan
    -- создать/удалить/обновтиь obvanPoint

 -- создать/удалить/обновтиь venue
    
 -- создать/удалить/обновтиь image
 
 
*/
