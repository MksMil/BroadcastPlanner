//import Combine
//import SwiftUI
//
//struct AddEditPointOrObvanView: View {
//  @EnvironmentObject var settings: GlobalSettings
//  @EnvironmentObject var dataManager: DataManager
//  @Environment(\.dismiss) var dismiss
//
//  @StateObject private var innerVm: AddEditPointOrObvanViewModel
//
//  let unit: LayoutRenderUnit
//  let broadcast: Broadcast
//
//  init(
//    unit: LayoutRenderUnit,
//    broadcast: Broadcast,
//    newObvanAction: @escaping (Obvan) -> Void
//  ) {
//    self.unit = unit
//    self.broadcast = broadcast
//    self._innerVm = StateObject(
//      wrappedValue: AddEditPointOrObvanViewModel(
//        broadcast: broadcast
//      )
//    )
//  }
//
//  var body: some View {
//
//    PointInfoPanelView()
//      .padding(.bottom, 20)
//      .onAppear {
//        //for alphabet sort of spec positions
//        innerVm.source = settings.userSpecialization
//      }
//      .environmentObject(innerVm)
//  }
//}
