import SwiftUI
import SpriteKit

struct BPEditConteinerView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editManager: EditPlanPointsManager
    @EnvironmentObject var settings: GlobalSettings
    
    @Binding var event: Event
    @State var title: String = ""
    
    var type: PlanSectionType = .car
    var editable: Bool
        
    //templates control
    var addTemplate: () -> Void = {}
    var updateTemplate: () -> Void = {}
    var removeTemplate: () -> Void = {}
    
    @State var isEditState: Bool = false
    
    @State private var stadiumFilter: BPEventPlanPointStadiumFilter = .all
    @State private var carFilter: BPEventPlanPointCarFilter = .all
    
    var filteredStadiumPoints: [BPEventPlanPoint] {
        let points = event.eventPlan.fieldPoints
        
        switch stadiumFilter {
            case .all:
                return points
            case .cam:
                return points.filter { point in
                    point.cam.optic != .none
                }
            case .light:
                return points.filter { point in
                    point.light.lightType != .none
                }
            case .mic:
                return points.filter { point in
                    point.mic.placeType != .none
                }
        }
    }
    var filteredCarPoints: [BPEventPlanPoint] {
        let points = event.eventPlan.carPoints
        
        switch carFilter {
            case .all:
                return points
            case .dir:
                return points.filter { point in
                    //                        point.cam.optic != .none
                    true
                }
            case .rep:
                return points.filter { point in
                    //                        point.light.lightType != .none
                    true
                }
            case .grf:
                return points.filter { point in
                    //                        point.mic.placeType != .none
                    true
                }
            case .sou:
                return points.filter { point in
                    //                        point.mic.placeType != .none
                    true
                }
        }
        
    }
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack{
                //filter
                Rectangle().fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .overlay {
                        HStack(spacing: 0){
                            
                            Button {
                                dismiss()
                                editManager.resetScale()
                                // TODO: selected point = nil!!!!
                                editManager.selectedEventPoint = nil
                                editManager.renderScene.deselect()
                                isEditState = false
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                            }
                            .padding(.leading,30)
                            Spacer()
                            if type == .stadium{
                                BPEventFilterCaseTabView(selectedTab:  $stadiumFilter)
                            } else {
                                BPEventFilterCaseTabView(selectedTab:  $carFilter)
                            }
                            Spacer()
                        }
                    }
                //templates choise
                if type == .stadium{
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "trash")
                                .padding(.horizontal,15)
                                .background{
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        Divider()
                            .frame(height: 30)
                        Menu {
                            ScrollView{
                                ForEach(settings.planPointsTemlates) { plan in
                                    Button("\(plan.title)") {
                                        print("chosen plan: \(plan.title) ")
                                        editManager.eventPlan = plan
                                        editManager.update(type: type)
                                        title = plan.title
                                    }
                                }
                            }
                        } label: {
                            Text(title)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal,15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        .onAppear{
                            title = event.eventPlan.title
                        }
                        
                        Spacer()
                        
                        Button {
                            print("new schema")
                        } label: {
                            Image(systemName: "plus")
                                .padding(.horizontal,15)
                                .background{
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        Button {
                            print("save schema")
                        } label: {
                            Image(systemName: "checkmark")
                                .padding(.horizontal,15)
                                .background{
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        
                    }
                    .padding(.horizontal,15)
                    .padding(.vertical,15)
                } else {
                    //bradcast car view
                    HStack {
                        Menu {
                            ScrollView{
                                ForEach(settings.planPointsTemlates) { plan in
                                    Button("broadcaster here") {
                                        print("broadcaster choosen")
                                    }
                                }
                            }
                        } label: {
                            Text("broadcaster")
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal,15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                        .frame(height: 45)
                                }
                        }
                        Menu {
                            ScrollView{
                                ForEach(settings.planPointsTemlates) { plan in
                                    Button("Car here") {
                                        
                                    }
                                }
                            }
                        } label: {
                            HStack{
                                Text("car name")
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal,15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                            .frame(height: 45)
                                    }
                                Image(systemName: "")
                            }
                        }
                        
                        Spacer()
                        
                      
                        
                    }
                    .padding(.horizontal,15)
                    .padding(.vertical,15)
                }
                //SKView
                
                    SpriteView(scene: editManager.renderScene)
                    .aspectRatio(1.5, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                
                  
                //control panel
                BPEditEventControlPanel(addAction: {editManager.addPoint()},
                                        deleteAction: {editManager.deletePoint()},
                                        saveAction: {editManager.save()},
                                        scaleUpAction: {editManager.scaleUp()},
                                        scaleDownAction: {editManager.scaleDown()},
                                        resetScaleAction: {editManager.resetScale()},
                                        isEdit: $isEditState)
                    .padding(.horizontal)
                //users collection
                
                BPEditEventBottomGroup(type: type,
                                       eventPlan: event.eventPlan,
                                       isEdit: $isEditState)
                .padding(.horizontal)
            }
//            .environmentObject(editManager)
        }
        .onReceive(editManager.$selectedEventPoint, perform: { value in
            if value != nil{
                isEditState = true
            } else {
                isEditState = false
            }
        })
    }
}

#Preview {
    BPEditConteinerView(event: .constant(MockData.sampleEvent),
                        type: .car,
                        editable: true)
    .environmentObject(EditPlanPointsManager())
    .environmentObject(MockData.sampleSettings)
    
}
