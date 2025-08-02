//
//  NewPointSelectionView.swift
//  BroadcastPlanner
//
//  Created by Миляев Максим on 31.07.2025.
//

import SwiftUI
import Combine

enum EditState: String {
    case point
    case obvan
    case new
}

@MainActor
final class AddEditPointOrObvanViewModel: ObservableObject{
    var number: Int = 0
    var selectedCameraOptic: String = "Empty"
    var selectedSoundPlaceType: String = "Empty"
    var selectedSoundWindDefence: String = "Empty"
    var selectedLight: String = "Empty"
    var selectedUser: Member?

    var position: String = "Unknown"

    var publisher: PassthroughSubject = PassthroughSubject<(PointEditPublishType, Any), Never>()

    let point: VenuePoint?
    let broadcast: Broadcast
    var availableNumbers: [Int] {
        var nums: [Int] = []
        
            nums = broadcast.viewVenuePoints.map{$0.viewNumber}
        
        nums.removeAll { num in
            num == number
        }
        var result = Array(1...50)
        result.removeAll { number in
            nums.contains(number)
        }
        return result
    }
    
    @Published var selectedObvan: Obvan?
    var sourceObvan: Obvan?
    var source: [String] = []
    

    init(point: VenuePoint?, selectedObvan: Obvan?,broadcast: Broadcast) {
        self.broadcast = broadcast
        self.selectedObvan = selectedObvan
        self.sourceObvan = selectedObvan
        
        self.point = point
        if let user = point?.viewMembers.first {
            selectedUser = user
        }

        if let camera = point?.viewCameras.first {
            selectedCameraOptic = camera.viewOptic
        }

        if let sound = point?.viewSounds.first {
            selectedSoundPlaceType = sound.viewPlaceType
            selectedSoundWindDefence = sound.viewWindDefence
        }

        if let light = point?.viewLights.first {
            selectedLight = light.viewLightType
        }
        number = point?.viewNumber ?? 0

        if let camPos = point?.pointDescription {
            position = camPos
        }
        
    }

}

struct AddEditPointOrObvanView: View {
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager
//    @EnvironmentObject var vm: BPEditStadiumViewModel
    @Environment(\.dismiss) var dismiss
    let state: EditState
    let broadcast: Broadcast
    
    @StateObject private var innerVm: AddEditPointOrObvanViewModel
   
    @State private var isPoint: Bool = true
    
    let newPointAction: (VenuePoint) -> Void
    let newObvanAction: (Obvan) -> Void
    
    init(state: EditState, broadcast: Broadcast, selectedPoint: VenuePoint?, selectedObvan: Obvan?, newPointAction: @escaping (VenuePoint)->(), newObvanAction: @escaping (Obvan)->() ){
        self.state = state
        self.broadcast = broadcast
        self._innerVm = StateObject(wrappedValue: AddEditPointOrObvanViewModel(point: selectedPoint, selectedObvan: selectedObvan,broadcast: broadcast))
        
        self.newPointAction = newPointAction
        self.newObvanAction = newObvanAction
    }

    var body: some View {
        VStack{
            switch state {
                    //edit
                case .point:
                    PointInfoPanelView()
                case .obvan:
                    ObvanInfoPanelView(broadcast: broadcast,
                        selectedObvan: innerVm.selectedObvan
                    )
                    //add new
                case .new:
                    VStack {
                        if isPoint {
                            PointInfoPanelView()
                        } else {
                            ObvanInfoPanelView(broadcast: broadcast,
                                               selectedObvan: nil)
                        }
                        Spacer()
                    }
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
                                dataManager.mainContext.delete(obvanToRemove)
                                broadcast.viewCrews.forEach { crew in
                                    if crew.viewObvanId == id{
                                        dataManager.mainContext.delete(crew)
                                    }
                                }
                            }
                            broadcast.addToObvan(newObvan)
                            newObvan.addToBroadcasts(broadcast)
                            try? dataManager.mainContext.save()
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
