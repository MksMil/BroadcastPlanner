import SpriteKit
import SwiftUI

struct BPEditStadiumView: View {

    @Environment(\.dismiss) var dismiss

    @StateObject var vm: BPEditStadiumViewModel

    @EnvironmentObject var settings: GlobalSettings

    let event: LocalEvent

    @State var title: String = ""

    //if user cant edit(he is not owner)
    var editable: Bool

    //templates control
    //    var addTemplate: () -> Void = {}
    //    var updateTemplate: () -> Void = {}
    //    var removeTemplate: () -> Void = {}

    //    @State var isEdit: Bool = false

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

    init(event: LocalEvent, editable: Bool) {
        self.event = event
        self.editable = editable
        self._vm = StateObject(wrappedValue: BPEditStadiumViewModel())
    }

    var body: some View {
        ZStack {
            MainBackground()
            
            ScrollView {
                //filter section

                ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false)
                {
                    // cancel
                    //rollback
                    dismiss()
                } acceptAction: {
                    dismiss()
                    vm.resetScale()
                    vm.selectedEventPoint = nil
                    vm.renderPitchScene.deselect()
                    vm.isEdit = false
                    //save context
                } content: {
                    BPEventFilterCaseTabView(selectedTab: $stadiumFilter)
                }
                .padding(.horizontal)

                //templates choise
                if editable {
                    //remove template
                    HStack {
                        Button {
                            print("template removed")
                        } label: {
                            Image(systemName: "trash")
                                .padding(.horizontal, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(
                                        .ultraThinMaterial
                                    )
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
                                .padding(.horizontal, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(
                                        .ultraThinMaterial
                                    )
                                    .frame(height: 45)
                                }
                        }
                        Button {
                            print("save schema")
                        } label: {
                            Image(systemName: "checkmark")
                                .padding(.horizontal, 15)
                                .background {
                                    RoundedRectangle(cornerRadius: 10).fill(
                                        .ultraThinMaterial
                                    )
                                    .frame(height: 45)
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                }
                //SKView

                SpriteView(
                    scene: vm.renderPitchScene,
                    debugOptions: [.showsFPS, .showsNodeCount]
                )
                .aspectRatio(1.5, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                

                //control panel
                // TODO: editable control
                HStack(spacing: 30) {
                    if editable {
                        SaveEditControlPanelView(
                            addAction: { vm.addPoint() },
                            deleteAction: { vm.deletePoint() },
                            saveAction: { vm.save() },
                            isEditAction: { vm.changeState() },
                            isEdit: vm.isEdit)
                    } else {
                        Spacer()
                    }
                    BPEditEventControlPanel(
                        scaleUpAction: { vm.scaleUp() },
                        scaleDownAction: { vm.scaleDown() },
                        resetScaleAction: { vm.resetScale() })
                }
                .padding(.horizontal)
                //users collection
                // TODO: editable control
                BPEditEventJoystickInfoPanel()
                    .environmentObject(vm)
                    .padding(.horizontal)
                    .frame(maxHeight: 290)
            }
            .scrollDisabled(true)
            
            
        }
        .navigationBarBackButtonHidden()
        
    }
}

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")
    
    BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
    .environmentObject(BPEditStadiumViewModel())
    .environmentObject(mdm)
}
