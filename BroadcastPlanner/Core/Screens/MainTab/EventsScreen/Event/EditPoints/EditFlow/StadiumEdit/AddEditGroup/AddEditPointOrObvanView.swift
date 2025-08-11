import SwiftUI
import Combine



struct AddEditPointOrObvanView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager
//    @EnvironmentObject var vm: BroadcastSchemaEditViewModel
    @Environment(\.dismiss) var dismiss
    let state: AddEditPointOrObvanState
    let broadcast: Broadcast
    
    @StateObject private var innerVm: AddEditPointOrObvanViewModel
   
    @State private var isPoint: Bool
    
    let newPointAction: (VenuePoint) -> Void
    let newObvanAction: (Obvan) -> Void
    
    init(state: AddEditPointOrObvanState,
         broadcast: Broadcast,
         selectedPoint: VenuePoint?,
         selectedObvan: Obvan?,
         newPointAction: @escaping (VenuePoint)->(),
         newObvanAction: @escaping (Obvan)->() ){
        self.state = state
        self.broadcast = broadcast
        self._innerVm = StateObject(wrappedValue: AddEditPointOrObvanViewModel(point: selectedPoint, selectedObvan: selectedObvan,broadcast: broadcast))
        
        self.newPointAction = newPointAction
        self.newObvanAction = newObvanAction
        self.isPoint = selectedPoint != nil || state == .new
    }

    var body: some View {
        VStack{
            
            VStack {
                if isPoint {
                    PointInfoPanelView()
                } else {
                    ObvanInfoPanelView(broadcast: broadcast,
                                       selectedObvan: innerVm.selectedObvan)
                }
                Spacer()
            }
            ConfirmationButtonGroupView(height: 60, isAcceptDisabled: false)
            {
                //cancel
                dataManager.rollBackMoc()
                dismiss()
            } acceptAction: {
                //accept
                switch state {
                    case .point:
                        if let point = innerVm.point{
                            dataManager.updatePoint(point, withNumber: innerVm.number, user: innerVm.selectedUser, optic: innerVm.selectedCameraOptic, placeType: innerVm.selectedSoundPlaceType, windDefence: innerVm.selectedSoundWindDefence, lightType: innerVm.selectedLight)
                            newPointAction(point)
                        }
                    case .obvan:
                        if let newObvan = innerVm.selectedObvan{
                        if let obvanToRemove = innerVm.sourceObvan,
                               newObvan != obvanToRemove{
                                let id = obvanToRemove.viewId
                            broadcast.removeFromObvan(obvanToRemove)
                            obvanToRemove.removeFromBroadcasts(broadcast)
                                broadcast.viewCrews.forEach { crew in
                                    if crew.viewObvanId == id{
                                        dataManager.mainContext.delete(crew)
                                    }
                                }
                            }
                            broadcast.addToObvan(newObvan)
                            newObvan.addToBroadcasts(broadcast)
                            try? dataManager.mainContext.save()
                            newObvanAction(newObvan)
                        }
                    case .new:
                        print("add new point or obvan")
                        if isPoint {
                            //create new point
                            let newPoint: VenuePoint = dataManager.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
                            dataManager.updatePoint(newPoint, withNumber: innerVm.number, user: innerVm.selectedUser, optic: innerVm.selectedCameraOptic, placeType: innerVm.selectedSoundPlaceType, windDefence: innerVm.selectedSoundWindDefence, lightType: innerVm.selectedLight)

                            newPointAction(newPoint)
                        } else {
                            //add obvan create crews
                            if let newObvan = innerVm.selectedObvan{
                                broadcast.addToObvan(newObvan)
                                newObvan.addToBroadcasts(broadcast)
                                try? dataManager.mainContext.save()
                                newObvanAction(newObvan)
                            }
                        }
                }
                dismiss()
            } content: {
                    HStack {
                        if state == .new{
                            Button {
                                withAnimation{
                                    isPoint = true
                                }
                            } label: {
                                Image(systemName: "sportscourt")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(60 / 4)
                                    .frame(height: 60)

                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill( .ultraThinMaterial)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(.ultraThickMaterial,
                                                            lineWidth: 2)
                                            }
                                    }
                                    .fixedSize()
                                    .opacity(!isPoint ? 0.3 : 1)
                            }
                            Button {
                                withAnimation{
                                    isPoint = false
                                }
                            } label: {
                                Image(systemName: "truck.box")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(60 / 4)
                                    .frame(height: 60)

                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill( .ultraThinMaterial)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(.ultraThickMaterial,
                                                            lineWidth: 2)
                                            }
                                    }
                                    .fixedSize()
                                    .opacity(isPoint ? 0.3 : 1)
                            }
                        } else {
                            Spacer()
                        }
                    }
               
            }
            .padding(.horizontal)
        }
        .onAppear{
            //for alphabet sort of spec positions
            innerVm.source = settings.userSpecialization
        }
        .environmentObject(innerVm)
    }
}

#if DEBUG
#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    dm.networkManager.eventProgressHandler = appState
    return RootView()
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)
}
#endif
