import SpriteKit
import SwiftUI

struct BPEditStadiumView: View {

    @StateObject var vm: BPEditStadiumViewModel

    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var eventRouter: EventTabRouter
    @EnvironmentObject var mdm: MainDataManager
    
    let event: LocalEvent

    @State var title: String = "Choose template"
    @State private var isConfirmDiscardChanges: Bool = false

    //if user cant edit(he is not owner)
    var editable: Bool

    @FetchRequest<LocalTemplate>(sortDescriptors: []) var templates
    
    init(event: LocalEvent, editable: Bool) {
        self.event = event
        self.editable = editable
        self._vm = .init(wrappedValue: BPEditStadiumViewModel(event: event))
    }

    var body: some View {
        ZStack {
            MainBackground()
            
            ScrollView {
                //filter section

                ConfirmationButtonGroupView(height: 50, isAcceptDisabled: false)
                {
                    isConfirmDiscardChanges = true                
                } acceptAction: {
                    vm.resetScale()
                    vm.selectedEventPoint = nil
                    vm.renderPitchScene.deselect()
                    vm.isEdit = false
                    //make snapshot and assign to event locationPreview
//                    vm.saveContext()
                    //save context
                    mdm.updateEvent(event, withPoints: vm.localPoints)
                    mdm.assignSnapshot(vm.makeSceneScreenshot(), toEvent: event)
                    eventRouter.routeStepBack()
                } content: {
                    BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter)
                }
                .padding(.horizontal)

                //templates choise
                if editable {
                    //template group
                    TemplateGroup(templates: templates) { templateToShow in
                        withAnimation {
                            vm.loadTemplate(mdm.makeLocalPointFromTemplate(templateToShow))
                            vm.selectedTemplate = templateToShow
                        }
                        
                    } addAction: { name in
                         mdm.saveTemplateFromSchema(localPoints: vm.localPoints, withName: name)
                        
                    } removeAction: {
                        withAnimation{
                            if let templateToRemove = vm.selectedTemplate{
                                mdm.removeLocalTemplate(templateToRemove)
                                vm.setEmptyTemplate()
                            }
                        }
                    } setEmptyTemplateAction: {
                        withAnimation{
                            vm.setEmptyTemplate()
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
                HStack(spacing: 30) {
                    if editable {
                        SaveEditControlPanelView(
                            addAction: {
                                //mdm: 'addPoint to event' & delegete it to scene
                                let newPoint = mdm.newPointInEvent(event,withNumber: vm.numberForNewPoint())
                                vm.addPoint(point: newPoint)
                            },
                            deleteAction: {
                                if let pointToDelete = vm.selectedEventPoint{
                                    vm.deletePoint()
                                    mdm.deletePoint(pointToDelete,
                                                    inEvent: event)
                                }
                            },
                            saveAction: {
                                if let point = vm.selectedEventPoint{
                                    mdm.updatePoint(point,
                                                    x: vm.coordinateX,
                                                    y: vm.coordinateY,
                                                    rotation: vm.rotation,
                                                    scaleFactor: vm.scaleFactor)
                                    vm.save()
                                }
                                },
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
                
                BPEditEventJoystickInfoPanel()
                    .environmentObject(vm)
                    .padding(.horizontal)
                    .frame(maxHeight: 290)
            }
            .scrollDisabled(true)
            
            
        }
        .task{
            vm.savePointAction = {
                if let point = vm.selectedEventPoint{
                    mdm.updatePoint(point,
                                    x: vm.coordinateX,
                                    y: vm.coordinateY,
                                    rotation: vm.rotation,
                                    scaleFactor: vm.scaleFactor)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isConfirmDiscardChanges) {
            Button("Discard all changes and step back?",role: .destructive){
                eventRouter.routeStepBack()
            }
        }
    }
}

#Preview {
    let mdm = MainDataManager(localDataManager: DataManager(), globalDataManager: NetworkManager(),userId: "123")

   return BPEditStadiumView(event: mdm.localDataManager.fetchOrCreateEventWithId("123", inContext: .main) , editable: true)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.moc)
}
