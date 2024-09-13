import SwiftUI
import SpriteKit

struct BPEditCarView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editManager: EditPlanPointsManager
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var globalStorage: GlobalStorage
    
    @Binding var event: Event
    
    @State var broadcasterTitle: String = "choose broadcaster"
    @State var carTitle: String = "choose car"

    
    //if user cant edit(he is not owner)
    var editable: Bool
    
    @State private var isEdit: Bool = true

    func saveToEvent(){
        if let broadcaster = editManager.selectedBroadcater{
            event.broadcaster =  broadcaster
        }
        if let car = editManager.selectedCar{
            event.broadcastCar = car
            editManager.loadScene(isPreview: true)
        }
    }
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack{
                //filter section
                Rectangle().fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .overlay {
                        HStack(spacing: 0){
                            //dissmiss
                            Button {
                                saveToEvent()
                                dismiss()
                                editManager.resetScale(type: .car)
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                            }
                            .padding(.leading,30)
                            
                            if editable{
                                Divider()
                                    .padding(.horizontal)
                                Menu {
                                    ScrollView{
                                        ForEach(settings.broadcasters) { bc in
                                            Button("\(bc.id)") {
                                                editManager.selectedBroadcater = bc
                                                broadcasterTitle = bc.id
                                            }
                                        }
                                    }
                                } label: {
                                    Text(broadcasterTitle)
                                        .frame(maxWidth: .infinity,alignment: .leading)
                                        .padding(.horizontal,25)
                                }
                            }
                        }
                    }
                
                //templates choise
                if editable{
                    HStack {
                       
                        Menu {
                            ScrollView{
                                ForEach(editManager.cars) { car in
                                    Button("\(car.name)") {
                                        editManager.selectedCar = car
                                    }
                                }
                            }
                        } label: {
                            Text(carTitle)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal,15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        Spacer()
                        
                    }
                    .padding(.horizontal,15)
                    .padding(.vertical,15)
                    .onReceive(editManager.$selectedBroadcater, perform: { value in
                        if let value {
                            broadcasterTitle = value.id
                        } else{
                            broadcasterTitle = "choose broadcaster"
                        }
                    }
                        )
                    .onReceive(editManager.$selectedCar, perform: { value in
                        if let value {
                            carTitle = value.name
                        } else {
                            carTitle = "choose car"
                        }
//
                    })
                }
                //SKView
                    SpriteView(scene: editManager.renderCarScene)
                    .aspectRatio(2.5, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .background{
                        RoundedRectangle(cornerRadius: 5).stroke( .ultraThinMaterial,lineWidth: 3)
                    }
                    .padding(.horizontal)
                
                BPEditEventControlPanel(scaleUpAction: {editManager.scaleUp(type: .car)},
                                        scaleDownAction: {editManager.scaleDown(type: .car)},
                                        resetScaleAction: {editManager.resetScale(type: .car)})
                    .padding(.horizontal)
              
                Spacer()
            }
        }
    }
    
    
}

#Preview {
    let manager = EditPlanPointsManager()
    manager.loadScene(isPreview: false)
    return BPEditCarView(event: .constant(MockData.sampleEvent),
                  editable: true)
    .environmentObject(manager)
    .environmentObject(MockData.sampleSettings)
    .environmentObject(GlobalStorage())
}
