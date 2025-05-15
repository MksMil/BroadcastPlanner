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
            
            VStack(spacing: 0) {
//                //filter section
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
                                // TODO: Edit location flow
                                print("edit event location")
                            }
                    
                }
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
                .padding(.vertical, 15)
                
                //SKView

                SpriteView(
                    scene: vm.renderPitchScene,
                    debugOptions: [.showsFPS, .showsNodeCount]
                )
                .aspectRatio(1.5, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
//
                
                GeometryReader{ geo in
                    let cellWidth = ((geo.size.width * 3 / 5 - 30) / 5).rounded()
                    //control panel
                    VStack{
                        HStack {
                            Spacer()
                            BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
                            Spacer()
//                            Divider()
                            //                    Spacer()
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
                                })
//                            .padding(.leading)
                            .frame(width: geo.size.width * 2 / 5)
                        }
                        .frame(height: 40)
                        .padding(.vertical,8)
                        
                        HStack(spacing: 0){
                            ScrollView{
                                VStack(alignment: .leading){
                                    HStack(spacing: 0){
                                        SmartLayout(hSpacing: 5, vSpacing: 5){
                                            ForEach(vm.filteredLocationPoints.sorted(by: {$0.viewNumber < $1.viewNumber})){ point in
                                                PointPanelCell(size: cellWidth,
                                                               state: vm.stateForPoint(point),
                                                               number: point.viewNumber,
                                                               isCamera: !point.viewLocalCameras.isEmpty,
                                                               isSound: !point.viewLocalSounds.isEmpty,
                                                               isLight: !point.viewLocalLights.isEmpty,
                                                               isUser: !point.viewUsers.isEmpty,
                                                               selectedPoint: $vm.selectedEventPoint)
                                                .onTapGesture {
                                                    withAnimation{
                                                        if vm.selectedEventPoint == point{
                                                            vm.deselectPointForRender()
                                                        } else {
                                                            vm.selectPoint(point: point)
                                                        }
                                                    }
                                                }
                                                .animation(.easeInOut, value: vm.selectedEventPoint)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 3 / 5)
//                            .border(Color.red)
                            VStack{
                                EventPointInfoPanelView()
                                
                                
                                Spacer()

                                BPEditEventControlPanel(
                                    scaleUpAction: { vm.scaleUp() },
                                    scaleDownAction: { vm.scaleDown() },
                                    resetScaleAction: { vm.resetScale() })
                                
                                BPJoystick(
                                    upAction: vm.moveUp,
                                    downAction: vm.moveDown,
                                    leftAction: vm.moveLeft,
                                    rightAction: vm.moveRight,
                                    rotationLeft: vm.rotateCounterClockwise,
                                    rotationRight: vm.rotateClockwise,
                                    swap: vm.swap,
                                    scaleUp: vm.scaleUpPoint,
                                    scaleDown: vm.scaleDownPoint
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .padding(15)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
                                }
                                
                            }
//                            .padding()
                            .frame(width: geo.size.width * 2 / 5)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .environmentObject(vm)
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
