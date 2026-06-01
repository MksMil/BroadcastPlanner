//
//  ObvanCollectionViewModel.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 01.06.2026.
//


import SwiftUI
@MainActor
class ObvanCollectionViewModel: ObservableObject {
  private let dataManager: DataManager
  private let router: Router
  
  @Published var isRemoveObvanDialog: Bool = false
  @Published var images: [String: UIImage] = [:] 


  init(dataManager: DataManager, router: Router) {
    self.dataManager = dataManager
    self.router = router
  }
  
  func loadImages(obvans: [Obvan]) async {
      for obvan in obvans {
          guard !obvan.viewImageId.isEmpty else { continue }
          let image = await dataManager.getImageWithId(
              obvan.viewImageId,
              type: .obvan,
              size: .smallImages
          )
          if let image {
              images[obvan.viewId] = image
          }
      }
  }
  
  
  func goBack() {
    router.stepBack()
  }
  
  func editSelectedObvan(obvan: Obvan){
      router.routeToEditObvan(obvan: obvan)
  }
  
  func addNewObvan(){
    router.routeToEditObvan(obvan: nil)
  }
}