import SpriteKit
import SwiftUI

struct BroadcastSchemaEditView: View {

    @EnvironmentObject var router: Router
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager
    
    @StateObject var vm: BroadcastSchemaEditViewModel
    
    let broadcast: Broadcast

    @State private var isConfirmDiscardChanges: Bool = false
    @State private var isEditPressed: Bool = false

    @FetchRequest<Template>(sortDescriptors: []) var templates
    @FetchRequest<Obvan>(sortDescriptors: []) var obvans
    
    init(broadcast: Broadcast) {
        self.broadcast = broadcast
        self._vm = .init(wrappedValue: BroadcastSchemaEditViewModel(broadcast: broadcast))
    }

    var body: some View {
        ZStack {
            MainBackground()
            
            VStack(spacing: 0) {
                //template group
//                TemplateGroup(templates: templates) { templateToShow in
//                    withAnimation {
//                        broadcast.cleanVenuePoints()
//                        Task{
//                            let points = await dataManager.makeLocalPointsFromTemplate(templateToShow)
//                            points.forEach { point in
//                                broadcast.addToVenuePoints(point)
//                                point.broadcast = broadcast
//                            }
//                            vm.loadTemplate(points)
//                            vm.selectedTemplate = templateToShow
//                            
//                        }
//                    }
//                } addAction: {
//                    appState.cleanTFInfo()
//                    appState.promptString = "Enter template name here"
//                    appState.fieldType = .custom(["cam"])
//                    appState.openTextFieldWithAction { name in
//                                            Task{
//                                                await dataManager.saveTemplateFromSchema(localPoints: vm.localPoints,
//                                                                                         withName: name)
//                                            }
//                    }
//                    
//                } removeAction: {
//                    Task{
//                       await dataManager.cleanLocalPoints(broadcast.viewVenuePoints, inEvent: broadcast)
//                    }
//                    withAnimation{
//                        if let templateToRemove = vm.selectedTemplate{
//                                vm.setEmptyTemplate()
//                                dataManager.removeLocalTemplate(templateToRemove)
//                        }
//                    }
//                } setEmptyTemplateAction: {
//                    Task{
//                       await dataManager.cleanLocalPoints(broadcast.viewVenuePoints, inEvent: broadcast)
//                    }
//                    withAnimation{
//                        vm.setEmptyTemplate()
//                    }
//                }
//                .padding(.vertical, 15)
//                
                //SKView

                SpriteView(
                    scene: vm.renderPitchScene,
                    debugOptions: [.showsFPS, .showsNodeCount]
                )
                .aspectRatio(1.5, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onAppear {
                    vm.loadScene()
                }

//                GeometryReader{ geo in
//                    let cellWidth = ((geo.size.width * 3 / 5 - 30) / 5).rounded()
//                    let obvanCellWidth = ((geo.size.width * 3 / 5 - 12) / 2).rounded()
//                    //control panel
//                    VStack(spacing: 0){
//                        HStack {
//                            Spacer()
//                            BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
//                            Spacer()
//
//                            SaveEditControlPanelView(
//                                addAction: {
//                                    //dataManager: 'addPoint to broadcast' & delegete it to scene
//                                    isEditPressed = true
//                                },
//                                deleteAction: {
//                                    if let pointToDelete = vm.selectedVenuePoint{
//                                        vm.deletePoint()
//                                        dataManager.deletePoint(pointToDelete)
//                                    }
//                                    if let obvanToRemove = vm.selectedObvan{
//                                        let id = obvanToRemove.viewId
//                                        vm.selectedObvan = nil
//                                        broadcast.removeFromObvan(obvanToRemove)
//                                        broadcast.viewCrews.forEach { crew in
//                                            if crew.viewObvanId == id{
//                                                dataManager.mainContext.delete(crew)
//                                            }
//                                        }
//                                    }
//                                    broadcast.lastUpdated = .now
//                                },
//                                saveAction: {
//                                    if let point = vm.selectedVenuePoint{
//                                        point.updateValues( x: vm.coordinateX,
//                                                            y: vm.coordinateY,
//                                                            rotation: Double(vm.rotation),
//                                                            scaleFactor: vm.scaleFactor,
//                                                            in: dataManager.mainContext)
//                                        vm.save()
//                                    } else if vm.selectedObvan != nil{
//                                        vm.selectedObvan = nil
//                                    }
//                                },
//                                editAction: {
//                                    isEditPressed = true
//                                }
//                            )
//                            .frame(width: geo.size.width * 2 / 5)
//                        }
//                        .frame(height: 40)
//                        .padding(.vertical,8)
//                        
//                        HStack(spacing: 0){
////                            ScrollView{
////                                VStack(alignment: .leading){
////                                    HStack(spacing: 0){
////                                        SmartCollection(hSpacing: 5, vSpacing: 5){
////                                            //obvans show
////                                            ForEach(obvans){obvan in
////                                                ObvanPanelCell(sizeW: obvanCellWidth,
////                                                               sizeH: cellWidth,
////                                                               obvanTitle: obvan.viewName,
////                                                               num: broadcast.crewsCountForObvan(obvan: obvan))
////                                                .opacity(vm.selectedObvan == obvan ? 1: 0.6)
////                                                .scaleEffect(vm.selectedObvan == obvan ? 1: 0.95)
////                                                .onTapGesture {
////                                                    withAnimation{
////                                                        if let point = vm.selectedVenuePoint{
////                                                            point.updateValues( x: vm.coordinateX,
////                                                                                y: vm.coordinateY,
////                                                                                rotation: Double(vm.rotation),
////                                                                                scaleFactor: vm.scaleFactor,
////                                                                                in: dataManager.mainContext)
////                                                            vm.deselectPointForRender()
////                                                        }
////                                                        vm.selectedObvan = vm.selectedObvan == obvan ? nil: obvan
////                                                    }
////                                                }
////                                            }
////                                        }
////                                    }
////                                        HStack(spacing: 0){
////                                            SmartCollection(hSpacing: 5, vSpacing: 5){
////                                            ForEach(vm.filteredLocationPoints.sorted(by: {$0.viewNumber < $1.viewNumber})){ point in
////                                                PointPanelCell(size: cellWidth,
////                                                               number: point.viewNumber,
////                                                               isCamera: !point.viewCameras.isEmpty,
////                                                               isSound: !point.viewSounds.isEmpty,
////                                                               isLight: !point.viewLights.isEmpty,
////                                                               isUser: !point.viewMembers.isEmpty)
////                                                .opacity(vm.selectedVenuePoint == point ? 1:0.6)
////                                                .scaleEffect(vm.selectedVenuePoint == point ? 1:0.95)
////                                                .onTapGesture {
////                                                    withAnimation{
////                                                        vm.selectedObvan = nil
////                                                        if let selectedPoint = vm.selectedVenuePoint{
////                                                            selectedPoint.updateValues( x: vm.coordinateX,
////                                                                                        y: vm.coordinateY,
////                                                                                        rotation: Double(vm.rotation),
////                                                                                        scaleFactor: vm.scaleFactor,
////                                                                                        in: dataManager.mainContext)
////                                                        }
////                                                        if vm.selectedVenuePoint == point{
////                                                            vm.deselectPointForRender()
////                                                        } else {
////                                                            vm.selectPoint(point: point)
////                                                        }
////                                                    }
////                                                }
////                                            }
////                                        }
////                                        Spacer()
////                                    }
////                                }
////                            }
////                            .frame(width: geo.size.width * 3 / 5)
//                            VStack{
//
//                                BPEditEventControlPanel(
//                                    scaleUpAction: { vm.scaleUp() },
//                                    scaleDownAction: { vm.scaleDown() },
//                                    resetScaleAction: { vm.resetScale() })
//                                
//                                BPJoystick(
//                                    upAction: vm.moveUp,
//                                    downAction: vm.moveDown,
//                                    leftAction: vm.moveLeft,
//                                    rightAction: vm.moveRight,
//                                    rotationLeft: vm.rotateCounterClockwise,
//                                    rotationRight: vm.rotateClockwise,
//                                    swap: vm.swap,
//                                    scaleUp: vm.scaleUpPoint,
//                                    scaleDown: vm.scaleDownPoint
//                                )
//                                .aspectRatio(1, contentMode: .fit)
//                                .padding(15)
//                                .overlay {
//                                    RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
//                                }
//                                Spacer()
//                            }
//                            .frame(width: geo.size.width * 2 / 5)
//                        }
//                    }
//                }
            }
            .padding(.horizontal)
            .transitionWithOpacity()
        }
//        .task{
//            vm.savePointAction = {
//                if let point = vm.selectedVenuePoint{
//                    point.updateValues(x: vm.coordinateX,
//                                       y:vm.coordinateY,
//                                       rotation: Double(vm.rotation),
//                                       scaleFactor: vm.scaleFactor,
//                                       in: dataManager.mainContext)
//                }
//            }
//        }
//        .onAppear{
//            let predicate = NSPredicate(format: "broadcasts CONTAINS %@", broadcast)
//            obvans.nsPredicate = predicate
//            appState.setTitle("\(broadcast.venue?.viewTitle ?? "") \( BPDateFormater.format(date: broadcast.viewDate))")
//            appState.primaryAction = {
//                let screenshot = vm.makeSceneScreenshot()
//                dataManager.assignSnapshot(screenshot,
//                                           toBroadcast: broadcast)
//                try? dataManager.saveContext(publish: .broadcasts,
//                                             id: [broadcast.viewId])
//                router.stepBack()
//            }
//            appState.secondaryAction = {
//                dataManager.rollBackMoc()
//            }
//            appState.stepBackAction = {
//                isConfirmDiscardChanges = true
//            }
//            
//        }
//        .ignoresSafeArea(.keyboard)
//        .navigationBarBackButtonHidden()
//        .confirmationDialog("", isPresented: $isConfirmDiscardChanges) {
//            Button("Discard all changes and step back?",role: .destructive){
//                dataManager.rollBackMoc()
//                router.stepBack()
//            }
//        }
//        .sheet(isPresented: $isEditPressed) {
//            if vm.selectedVenuePoint != nil{
//                AddEditPointOrObvanView(state: .point,
//                                        broadcast: broadcast,
//                                        selectedPoint: vm.selectedVenuePoint,
//                                        selectedObvan: nil) { updatedPoint in
//                    vm.updatePoint(updatedPoint)
//                } newObvanAction: { _ in }
//                .presentationBackground(Color.mainBackground)
//                .presentationDragIndicator(.visible)
//            } else if vm.selectedObvan != nil{
//                AddEditPointOrObvanView(state: .obvan,
//                                        broadcast: broadcast,
//                                        selectedPoint: nil,
//                                        selectedObvan: vm.selectedObvan) { _ in} newObvanAction: { obvan in
//                    vm.selectedObvan = obvan
//                }
//                .presentationBackground(Color.mainBackground)
//                .presentationDragIndicator(.visible)
//            } else {
//                AddEditPointOrObvanView(state: .new, broadcast: broadcast, selectedPoint: nil, selectedObvan: nil, newPointAction: { newVenuePoint in
//                    broadcast.addToVenuePoints(newVenuePoint)
//                    newVenuePoint.broadcast = broadcast
//                    vm.addPoint(point: newVenuePoint)
//                }, newObvanAction: { obvan in
//                    vm.selectedObvan = obvan
//                })
//                .presentationBackground(Color.mainBackground)
//                .presentationDragIndicator(.visible)
//            }
//        }
//        .environmentObject(vm)
//        .onReceive(vm.$selectedObvan) { obvan in
//            if obvan == nil , vm.selectedVenuePoint == nil{
//                appState.makePrimaryButtonEnabled(true)
//            } else {
//                appState.makePrimaryButtonEnabled(false)
//            }
//        }
//        .onReceive(vm.$selectedVenuePoint) { point in
//            if point == nil , vm.selectedObvan == nil{
//                appState.makePrimaryButtonEnabled(true)
//            } else {
//                appState.makePrimaryButtonEnabled(false)
//            }
//        }
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
