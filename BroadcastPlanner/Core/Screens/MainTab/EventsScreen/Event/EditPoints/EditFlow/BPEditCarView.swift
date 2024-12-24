import SwiftUI
import SpriteKit
//import CoreData

struct BPEditCarView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var editManager: BPEditStadiumViewModel
    @EnvironmentObject var settings: GlobalSettings
    
    @FetchRequest<LocalBroadcaster>(sortDescriptors: []) var broadcasters
    
    let event: LocalEvent
    
    @State var broadcasterTitle: String = "choose broadcaster"
    @State var carTitle: String = "choose car"

    @State private var isEnabled: Bool = true
    @State private var isSelectTemplate: Bool = false
    @State private var selectedUnit: LocalObvanUnit?
    
    //if user cant edit(he is not owner)
    var editable: Bool
    
    @State private var isEdit: Bool = true
    @State private var selectedUnits: [LocalObvanUnit] = []
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack{
                //exit without save
                Rectangle().fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .overlay {
                        HStack(spacing: 0){
                            //dissmiss
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title)
                            }
                            .padding(.leading,20)
                            
                            if editable{
                                Divider()
                                    .padding(.horizontal)
                                Menu {
//                                    ScrollView{
//                                        ForEach(broadcasters) { bc in
//                                            Button("\(bc.viewTitle)") {
//                                                editManager.selectedBroadcaster = bc
//                                                broadcasterTitle = bc.viewTitle
//                                            }
//                                        }
//                                        Button("+ new broadcaster") {
//                                            // TODO: add broadcaster flow
//                                            print("add new broadcaster")
//                                        }
////                                        .disabled(true)
//                                    }
                                } label: {
                                    Text(broadcasterTitle)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal,25)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            Button {
                                editManager.resetScale(type: .car)
                                saveToEvent()
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                            }
                            .padding(.trailing,20)
                        }
                    }
                
                //templates choise
                if editable{
                    HStack {
                        Menu {
//                            if let broadcaster = editManager.selectedBroadcaster{
//                                ScrollView{
//                                    ForEach(broadcaster.viewCars) { car in
//                                        Button("\(car.viewTitle)") {
//                                            editManager.selectedCar = car
//                                        }
//                                    }
//                                    Button("+ new car") {
//                                        print("add new car")
//                                    }
//                                    //                                        .disabled(true)
//                                }
//                            }
                        } label: {
                            Text(carTitle)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        .padding(.horizontal,65)
                    }
                    .padding(.vertical,10)
//                    .onReceive(editManager.$selectedBroadcaster, perform: { value in
//                        if let value {
//                            broadcasterTitle = value.id
//                            editManager.selectedCar = nil
//                        } else{
//                            broadcasterTitle = "choose broadcaster"
//                        }
//                    }
//                        )
//                    .onReceive(editManager.$selectedCar, perform: { value in
//                        if let value {
//                            carTitle = value.name
//                        } else {
//                            carTitle = "choose car"
//                        }
////
//                    })
                }
                //SKView
//                    SpriteView(scene: editManager.renderCarScene)
//                    .aspectRatio(2.5, contentMode: .fit)
//                    .frame(maxWidth: .infinity)
//                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                    .background{
//                        RoundedRectangle(cornerRadius: 5).stroke( .ultraThinMaterial,lineWidth: 3)
//                    }
//                    .padding(.horizontal)
                    
                HStack{
                    RoundedRectangle(cornerRadius: 10)
                          .fill(.ultraThinMaterial)
                          .shadow(radius: 1)
                          .frame(height: 45)
                    
                    BPEditEventControlPanel(scaleUpAction: {editManager.scaleUp(type: .car)},
                                            scaleDownAction: {editManager.scaleDown(type: .car)},
                                            resetScaleAction: {editManager.resetScale(type: .car)})
                    .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 10)
                          .fill(.ultraThinMaterial)
                          .shadow(radius: 1)
                          .frame(height: 45)
                          .overlay {
                              Button("select") {
                                  isSelectTemplate.toggle()
                              }
                          }
                }
                .padding(.horizontal)
                Spacer()
                
//                ScrollView(.vertical) {
//                    ForEach(showSelectedUnits()) { carUnit in
//                        CarUnitCellView(position: carUnit.position.rawValue,
//                                        firstName: "Aleksander",
//                                        lastName: "Garibaishvilli",
//                                        action: {
//                            
//                        },
//                                        infoAction: {
//                            
//                        })
//                        .padding(.horizontal)
//                    }
//                }
                
            }
//            .sheet(isPresented: $isSelectTemplate, content: {
//                VStack{
//                    ScrollView(.vertical) {
//                        ForEach(makeCarUnits()) { carUnit in
//                            CarUnitEnableCellView(position: carUnit.position.rawValue,
//                                            isEnabled: carUnit.isEnabled,
//                                                  action: {
//                                editManager.setEnabledToUnit(name: carUnit.id)
//                            })
//                            .padding(.horizontal)
//                        }
//                    }
//                    HStack{
//                        Button("Save") {
////                            selectedUnits = editManager.selectedCar?.units ?? []
//                            isSelectTemplate.toggle()
//                        }
//                        .padding()
//                        .background {
//                            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
//                        }
//                    }
//                }
//                .presentationDetents([.fraction(0.65)])
//            }
//            )
//            .sheet(item: $selectedUnit) {
//                //on dissmiss
//            } content: { item in
//                let _ = print("item")
//                Text("")
//            }
        }
//        .onReceive(editManager.$selectedCar, perform: { val in
//            if let val {
//                selectedUnits = val.units
//            }
//        })
    }
    
    func makeCarUnits() -> [LocalObvanUnit]{
//        if let carUnits = editManager.selectedCar?.units{
//            return carUnits
//        } else{
            return []
//        }
    }
    
//    func showSelectedUnits() -> [LocalOBVanUnit]{
//        selectedUnits.filter { $0.isEnabled }
//    }
    
    func saveToEvent(){
//        if let broadcaster = editManager.selectedBroadcaster{
//            event.broadcaster =  broadcaster
//        }
//        if let car = editManager.selectedCar{
//            event.broadcastCar = car
//            editManager.loadScene()
//        }
    }
}

#Preview {
    
    return BPEditCarView(event: DataManager.shared.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
        .environmentObject(BPEditStadiumViewModel())
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
