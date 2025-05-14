import SpriteKit
import SwiftUI

struct BPEditStadiumView: View {

    @StateObject var vm: BPEditStadiumViewModel

    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var eventRouter: EventTabRouter
    @EnvironmentObject var mdm: MainDataManager
    
    let event: Event

    @State var title: String = "Choose template"
    @State private var isConfirmDiscardChanges: Bool = false

    @FetchRequest<Template>(sortDescriptors: []) var templates
    
    init(event: Event) {
        self.event = event
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
                    mdm.updateEvent(event, withPoints: vm.localPoints)
                    Task{
                       await mdm.assignSnapshot(vm.makeSceneScreenshot(), toEvent: event)
                        eventRouter.routeStepBack()
                    }
                } content: {
//                    BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
//                    Spacer()
                   
//                        Image(systemName: "trash")
//                            .resizable()
//                            .scaledToFit()
                    
                    Text("\(event.viewTitle)")
                        .font(.title)
                            .bold()
                            .minimumScaleFactor(0.1)
                            .padding(50 / 4)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(.ultraThickMaterial
                                        .opacity(0.3))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(
                                                .ultraThickMaterial
                                                .opacity(0.5),
                                                    lineWidth: 2)
                                    }
                            }
                            .onTapGesture {
                                print("edit event location")
                            }
                    
                }
                .padding(.horizontal)

                //templates choise
                
                    //template group
                    TemplateGroup(templates: templates) { templateToShow in
                        withAnimation {    
                                let template =  mdm.makeLocalPointFromTemplate(templateToShow)
                                
                                    vm.loadTemplate(template)
                                    vm.selectedTemplate = templateToShow
                        }
                        
                    } addAction: { name in
                        Task{
                           await mdm.saveTemplateFromSchema(localPoints: vm.localPoints, withName: name)
                        }
                    } removeAction: {
                        withAnimation{
                            if let templateToRemove = vm.selectedTemplate{
                                Task{
                                  await mdm.removeLocalTemplate(templateToRemove)
                                    vm.setEmptyTemplate()
                                }
                            }
                        }
                    } setEmptyTemplateAction: {
                        withAnimation{
                            vm.setEmptyTemplate()
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                
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
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: Event.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.mainContext) { ctx in
        let newEvent = Event(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
   return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
}
