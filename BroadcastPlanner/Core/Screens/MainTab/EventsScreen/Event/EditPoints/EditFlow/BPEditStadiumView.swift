import SwiftUI
import SpriteKit

struct BPEditStadiumView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var editManager: EditPlanPointsManager
    @EnvironmentObject var settings: GlobalSettings
    
    @Binding var event: LocalEvent
    
    @State var title: String = ""
    
    //if user cant edit(he is not owner)
    var editable: Bool
        
    //templates control
    var addTemplate: () -> Void = {}
    var updateTemplate: () -> Void = {}
    var removeTemplate: () -> Void = {}
    
    @State var isEdit: Bool = false
    
    @State private var stadiumFilter: BPEventPlanPointStadiumFilter = .all
    
//    var filteredStadiumPoints: [LocationPoint] {
//        let points = event.eventPlan.fieldPoints
//        switch stadiumFilter {
//            case .all:
//                return points
//            case .cam:
//                return points.filter { point in
//                    point.cam.optic != .none
//                }
//            case .light:
//                return points.filter { point in
//                    point.light.lightType != .none
//                }
//            case .mic:
//                return points.filter { point in
//                    point.mic.placeType != .none
//                }
//        }
//    }

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
                                dismiss()
                                editManager.resetScale(type: .stadium)
                                // TODO: selected point = nil!!!!
                                editManager.selectedEventPoint = nil
                                editManager.renderPitchScene.deselect()
                                isEdit = false
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title)
                            }
                            .padding(.leading,30)
                            
                            //filter
                            BPEventFilterCaseTabView(selectedTab:  $stadiumFilter)
                        }
                    }
                
                //templates choise
                if editable{
                    //remove template
                    HStack {
                        Button {
                            print("template removed")
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
//                        Menu {
//                            ScrollView{
//                                ForEach(settings.planPointsTemlates) { plan in
//                                    Button("\(plan.title)") {
//                                        title = plan.title
//                                    }
//                                }
//                            }
//                        } label: {
//                            Text(title)
//                                .frame(maxWidth: .infinity)
//                                .padding(.horizontal,15)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
//                                        .frame(height: 45)
//                                }
//                        }
//                        .onAppear{
//                            title = event.eventPlan.title
//                        }
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
                }
                //SKView
                
                    SpriteView(scene: editManager.renderPitchScene)
                    .aspectRatio(1.5, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
                  
                //control panel
                // TODO: editable control
                HStack(spacing: 30){
                    if editable{
                        SaveEditControlPanelView(addAction: {editManager.addPoint()},
                                                 deleteAction: {editManager.deletePoint()},
                                                 saveAction: {editManager.save()},
                                                 isEdit: $isEdit)
                    } else {
                        Spacer()
                    }
                    BPEditEventControlPanel(scaleUpAction: {editManager.scaleUp(type: .stadium)},
                                            scaleDownAction: {editManager.scaleDown(type: .stadium)},
                                            resetScaleAction: {editManager.resetScale(type: .stadium)})
                }
                .padding(.horizontal)
                
                //users collection
                
                // TODO: editable control
//                BPEditEventBottomGroup(eventPlan: event.eventPlan,
//                                       isEdit: $isEdit)
                .padding(.horizontal)
            }
        }
        .onReceive(editManager.$selectedEventPoint, perform: { value in
            if value != nil{
                isEdit = true
            } else {
                isEdit = false
            }
        })
    }
}

//#Preview {
//    BPEditStadiumView(event: .constant(MockData.sampleEvent),
//                      editable: true)
//    .environmentObject(EditPlanPointsManager())
//    .environmentObject(MockData.sampleSettings)
//}
