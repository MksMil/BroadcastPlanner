import SpriteKit
import SwiftUI

struct BPEditStadiumView: View {

    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject var vm: BPEditStadiumViewModel
    
    let broadcast: Broadcast

    @State private var isConfirmDiscardChanges: Bool = false
    @State private var isEditPressed: Bool = false

    @FetchRequest<Template>(sortDescriptors: []) var templates
    
    init(broadcast: Broadcast) {
        self.broadcast = broadcast
        self._vm = .init(wrappedValue: BPEditStadiumViewModel(broadcast: broadcast))
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
//                    dataManager.updateEvent(broadcast, withPoints: vm.localPoints)
//                    Task{
//                        await dataManager.assignSnapshot(vm.makeSceneScreenshot(), toEvent: broadcast)
//                        await dataManager.saveContextAsync(type: .main, publish: .broadcasts, id: [broadcast.viewId])
//                        eventRouter.routeStepBack()
//                    }
                } content: {
                    Text("\(broadcast.viewTitle)")
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
                                // TODO: Select / Edit venue flow
                                print("edit broadcast venue")
                                
                            }
                    
                }
                //template group
                TemplateGroup(templates: templates) { templateToShow in
                    withAnimation {
//                        dataManager.cleanLocalPoints(broadcast.viewVenuePoints, inEvent: broadcast)
//                        let points =  dataManager.makeLocalPointsFromTemplate(templateToShow)
//                        dataManager.loadTemplatePoints(points, toEvent: broadcast)
//                        vm.loadTemplate(points)
//                        vm.selectedTemplate = templateToShow
                    }
                    
                } addAction: { name in
//                    Task{
//                        await dataManager.saveTemplateFromSchema(localPoints: vm.localPoints, withName: name)
//                    }
                } removeAction: {
//                    dataManager.cleanLocalPoints(broadcast.viewVenuePoints, inEvent: broadcast)
//                    withAnimation{
//                        if let templateToRemove = vm.selectedTemplate{
//                            Task{
//                                vm.setEmptyTemplate()
//                                await dataManager.removeLocalTemplate(templateToRemove)
//                            }
//                        }
//                    }
                } setEmptyTemplateAction: {
//                    dataManager.cleanLocalPoints(broadcast.viewVenuePoints, inEvent: broadcast)
//                    withAnimation{
//                        vm.setEmptyTemplate()
//                    }
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
                    VStack(spacing: 0){
                        HStack {
                            Spacer()
                            BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
                            Spacer()
//                            Divider()
                            //                    Spacer()
                            SaveEditControlPanelView(
                                addAction: {
                                    //dataManager: 'addPoint to broadcast' & delegete it to scene
//                                    let newPoint = dataManager.newPointInEvent(broadcast,withNumber: vm.numberForNewPoint())
//                                    vm.addPoint(point: newPoint)
                                },
                                deleteAction: {
//                                    if let pointToDelete = vm.selectedEventPoint{
//                                        vm.deletePoint()
//                                        dataManager.deletePoint(pointToDelete,
//                                                        inEvent: broadcast)
//                                    }
                                },
                                saveAction: {
//                                    if let point = vm.selectedEventPoint{
//                                        dataManager.updatePoint(point,
//                                                        x: vm.coordinateX,
//                                                        y: vm.coordinateY,
//                                                        rotation: vm.rotation,
//                                                        scaleFactor: vm.scaleFactor)
//                                        vm.save()
//                                    }
                                },
                                editAction: {
//                                    if let point = vm.selectedEventPoint{
//                                        print("edit point")
//                                        //present edit sheet
//                                    }
                                    isEditPressed = true
                                }
                            )
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
                                                               isCamera: !point.viewCameras.isEmpty,
                                                               isSound: !point.viewSounds.isEmpty,
                                                               isLight: !point.viewLights.isEmpty,
                                                               isUser: !point.viewMembers.isEmpty,
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
//                                EventPointInfoPanelView()
//                                
//                                
//                                Spacer()

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
                                Spacer()
                            }
                            .frame(width: geo.size.width * 2 / 5)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .transitionWithOpacity()
        }
        .onAppear{
            appState.applyAppConfiguration(StateCongiguration.StadPointsEditViewConfiguration)
            appState.primaryAction = {
                vm.resetScale()
                vm.selectedEventPoint = nil
                vm.renderPitchScene.deselect()
                vm.isEdit = false
                
                broadcast.updateValues(venuePoints: vm.localPoints,in: dataManager.mainContext)
                Task{
                    await dataManager.assignSnapshot(vm.makeSceneScreenshot(), toEvent: broadcast)
                    
                    try? dataManager.saveContext(publish: .broadcasts, id: [broadcast.viewId])
                    router.stepBack()
                }
            }
            appState.secondaryAction = {
                isConfirmDiscardChanges = true
            }
            appState.stepBackAction = {
//                dataManager.mainContext.rollback()
                router.stepBack()
            }
            
        }
        .task{
            vm.savePointAction = {
                if let point = vm.selectedEventPoint{
                    
                    point.updateValues(x: vm.coordinateX,
                                       y:vm.coordinateY,
                                       rotation: Double(vm.rotation),
                                       scaleFactor: vm.scaleFactor,
                                       in: dataManager.mainContext)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .confirmationDialog("", isPresented: $isConfirmDiscardChanges) {
            Button("Discard all changes and step back?",role: .destructive){
                dataManager.rollBackMoc()
                router.stepBack()
            }
        }
        .sheet(isPresented: $isEditPressed) {
            if let point = vm.selectedEventPoint{
                PointInfoPanelView(point: point){ pointNum, pointUser, pointOptic,pointPlace,pointWD,pointLight in
                    print("save venuePoint")
//                    dataManager.updatePoint(point, withNumber: pointNum, user: pointUser, optic: pointOptic, placeType: pointPlace, windDefence: pointWD, lightType: pointLight)
                    vm.updatePoint(point)
                }
                    .presentationBackground(Color.mainBackground)
            }
        }
        .environmentObject(vm)
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
