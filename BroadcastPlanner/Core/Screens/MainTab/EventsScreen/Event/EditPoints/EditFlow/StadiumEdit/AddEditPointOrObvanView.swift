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
    var number: Int = 0{
        didSet{
            print("now number \(number)")
        }
    }
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
    @Published var previewsCrew: [CrewPreview] = []

    var source: [String] = []
    
    func make(){
        if let selectedObvan {
            var existingCrews = broadcast.viewCrews.filter { crew in
                crew.viewObvanId == selectedObvan.viewId
            }
            var result:[CrewPreview] = []
            selectedObvan.viewTemplateCrews.forEach { template in
                let position = template.viewPosition
                let member = existingCrews.first { crew in
                    crew.viewPosition == position
                }?.member
                let hardware = existingCrews.first { crew in
                    crew.viewPosition == position
                }?.hardware
                
                result.append(CrewPreview(position: position, member: member, hardware: hardware?.viewType,template: template))
                existingCrews.removeAll { crew in
                    crew.member == member
                }
            }
            previewsCrew = result.sorted(by: { first, second in
                source.firstIndex(of: first.position) ?? 0 < source.firstIndex(of: second.position) ?? 0
            })
        } else {
            previewsCrew = []
        }
        
    }

    init(point: VenuePoint?, selectedObvan: Obvan?,broadcast: Broadcast) {
        self.broadcast = broadcast
        self.selectedObvan = selectedObvan
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
                case .point:
                    PointInfoPanelView()
                case .obvan:
                    ObvanInfoPanelView(
                        selectedObvan: innerVm.selectedObvan
                    )
                case .new:
                    VStack {
                        if isPoint {
                            PointInfoPanelView()
                        } else {
                            ObvanInfoPanelView(selectedObvan: nil)
                        }
                        Spacer()
                    }
            }
            ConfirmationButtonGroupView(height: 60, isAcceptDisabled: false)
            {
                //cancel
                
                dismiss()
            } acceptAction: {
                //accept
                switch state {
                    case .point:
                        print("point update")
                        //                    dataManager.updatePoint(point, withNumber: pointNum, user: pointUser, optic: pointOptic, placeType: pointPlace, windDefence: pointWD, lightType: pointLight)
                        //                    vm.updatePoint(point)
                        //                    newPointAction()
//                    }
                    case .obvan:
                        print("obvan update")
                        //accept
                        //                // if new obvan replace old
                        //                if let sourceObvan,let newObvan = vm.selectedObvan, newObvan != sourceObvan{
                        //                    let obvanId = sourceObvan.viewId
                        //                    broadcast.removeFromObvan(sourceObvan)
                        //                    broadcast.viewCrews.forEach { crew in
                        //                        if crew.obvanId == obvanId{
                        //                            dataManager.mainContext.delete(crew)
                        //                        }
                        //                    }
                        //                }
                        //                //confirm new obvan and crews
                        //                if let selectedObvan = vm.selectedObvan{
                        //                    broadcast.addToObvan(selectedObvan)
                        //                    let obvanId = selectedObvan.viewId
                        //                    for preview in vm.previewsCrew{
                        //                        let hardware: Hardware = dataManager.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
                        //                        hardware.updateValues(type: preview.hardware)
                        //                        let newCrew: Crew = dataManager.mainContext.fetchOrCreateObject(withID: UUID().uuidString)
                        //                        newCrew.updateValues(position: preview.position, x: Double(preview.template.coordinateX), y: Double(preview.template.coordinateY), scaleFactor: Double(preview.template.scaleFactor), rotation: Double(preview.template.rotation), task: nil, member: preview.member, hardware: hardware, broadcast: broadcast, obvanId: obvanId, in: dataManager.mainContext)
                        //                        hardware.crew = newCrew
                        //                        preview.member?.addToCrews(newCrew)
                        //                        broadcast.addToCrews(newCrew)
                        //                    }
                        //                }
                        //                try? dataManager.mainContext.save()
                    case .new:
                        print("add new point or obvan")
                        //create new point
                        
                        //                    dataManager.updatePoint(point, withNumber: pointNum, user: pointUser, optic: pointOptic, placeType: pointPlace, windDefence: pointWD, lightType: pointLight)
                        //                    vm.updatePoint(point)
                        //                    newPointAction()
                        //                            }
                        // --OR--
                        //create new obvan point
                }
                
                dismiss()
            } content: {
                    HStack {
                        if state == .new{
                            Button {
                                isPoint = true
                            } label: {
                                Text("Point")
                            }
                            Button {
                                isPoint = false
                            } label: {
                                Text("Obvan")
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
