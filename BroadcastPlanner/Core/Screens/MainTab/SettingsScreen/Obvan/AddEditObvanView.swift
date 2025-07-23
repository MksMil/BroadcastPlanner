import SwiftUI
import SpriteKit
import _PhotosUI_SwiftUI

struct AddEditObvanView: View {
    
    @EnvironmentObject var appState: ApplicationState
    @EnvironmentObject var globalSettings: GlobalSettings
    @EnvironmentObject var dataManager: DataManager

    @EnvironmentObject var router: Router
    @StateObject var vm: AddEditObvanViewModel
    
    @State var isEditPressed: Bool = false
    
    let obvan: Obvan
    
    init(obvan: Obvan){
        self.obvan = obvan
        self._vm = StateObject(wrappedValue: AddEditObvanViewModel(obvan: obvan))
    }
    
    var body: some View {
        ZStack{
         MainBackground()
            VStack(spacing: 0){
                //choose back image from library
                
                
                //accessAction(add to SKScene) in vm?
                
                //scscene
                SpriteView(scene: vm.renderObvanScene, debugOptions: [.showsFPS,.showsNodeCount])
//                    .aspectRatio( contentMode: .fill)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5).stroke( Color.black)
                            
                    })
                    .padding(.horizontal)
                //add edit panel
                
                //collection of crew
                
                //joystick
                
                GeometryReader{ geo in
//                    let cellWidth = ((geo.size.width * 3 / 5 - 30) / 5).rounded()
                    //control panel
                    VStack(spacing: 0){
                        HStack {
                            Button{
                                vm.uiimage = UIImage(named: "empty_babybird")
                            } label: {
                                Image(systemName: "bus")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(5)
                                    .frame(width: 40, height: 40)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(
                                                .ultraThickMaterial
                                                    .opacity(0.3)
                                            )
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(
                                                        .ultraThickMaterial
                                                            .opacity(0.5),
                                                        lineWidth: 2
                                                    )
                                            }
                                    }
                            }
                            Button{
                                vm.uiimage = UIImage(named: "empty_starbird")
                            } label: {
                                Image(systemName: "bus.doubledecker")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(5)
                                    .frame(width: 40, height: 40)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(
                                                .ultraThickMaterial
                                                    .opacity(0.3)
                                            )
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(
                                                        .ultraThickMaterial
                                                            .opacity(0.5),
                                                        lineWidth: 2
                                                    )
                                            }
                                    }
                            }
                            
                                                        Spacer()
                            //                            BPEventFilterCaseTabView(selectedTab: $vm.stadiumFilter){}
                            PhotosPicker(selection: $vm.selectedPhoto) {
                                //photo.artframe
                                Image(systemName: "photo.artframe")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .padding(5)
                                    .frame(width: 40, height: 40)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(
                                                .ultraThickMaterial
                                                    .opacity(0.3)
                                            )
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(
                                                        .ultraThickMaterial
                                                            .opacity(0.5),
                                                        lineWidth: 2
                                                    )
                                            }
                                    }
                            }
//                            Spacer()
                            
                            ObvanControlPanel(isEdit: $vm.isEdit,
                                addAction: {
                                    //dataManager: 'addPoint to broadcast' & delegete it to scene
                                    //                                    let newPoint = dataManager.newPointInEvent(broadcast,withNumber: vm.numberForNewPoint())
                                    //                                    vm.addPoint(point: newPoint)
                                    dataManager.mainContext.performAndWait{
                                        let id = UUID().uuidString
                                        let newTemplateCrew: ObvanTemplateCrew = dataManager.mainContext.fetchOrCreateObject(withID: id)
                                        vm.addObvanTemplateCrew(newTemplateCrew)
                                        isEditPressed = true
                                    }
                                },
                                deleteAction: {
                                    if let crewToDelete = vm.selectedCrew{
                                        vm.deleteObvanTemplateCrew(crewToDelete)
//                                        dataManager.deleteCrew
                                    }
                                    //                                    if let pointToDelete = vm.selectedEventPoint{
                                    //                                        vm.deletePoint()
                                    //                                        dataManager.deletePoint(pointToDelete,
                                    //                                                        inEvent: broadcast)
                                    //                                    }
                                },
                                saveAction: {
                                    if let crew = vm.selectedCrew{
                                        crew.updateWithValues(x: vm.coordinateX,
                                                              y: vm.coordinateY,
                                                              rotation: Double(vm.rotation),
                                                              scaleFactor: vm.scaleFactor,
                                                              position: vm.position,
                                                              isRequired: true,
                                                              in: dataManager.mainContext)
                                        vm.deselectCrewForRenderer()
                                    }
                                },
                                editAction: {
                                    isEditPressed = true
                                }
                            )
                            .frame(width: geo.size.width * 2 / 5)
                        }
                        .frame(height: 40)
                        .padding(.vertical,8)
                        
                        HStack(spacing: 0){
                            ScrollView{
                                VStack(alignment: .leading){
                                    HStack(spacing: 0){
                                        //List of crews
                                        
                                        
                                        //                                        SmartLayout(hSpacing: 5, vSpacing: 5){
                                        //                                            ForEach(vm.filteredLocationPoints.sorted(by: {$0.viewNumber < $1.viewNumber})){ point in
                                        //                                                PointPanelCell(size: cellWidth,
                                        //                                                               state: vm.stateForPoint(point),
                                        //                                                               number: point.viewNumber,
                                        //                                                               isCamera: !point.viewCameras.isEmpty,
                                        //                                                               isSound: !point.viewSounds.isEmpty,
                                        //                                                               isLight: !point.viewLights.isEmpty,
                                        //                                                               isUser: !point.viewMembers.isEmpty,
                                        //                                                               selectedPoint: $vm.selectedEventPoint)
                                        //                                                .onTapGesture {
                                        //                                                    withAnimation{
                                        //                                                        if vm.selectedEventPoint == point{
                                        //                                                            vm.deselectPointForRender()
                                        //                                                        } else {
                                        //                                                            vm.selectPoint(point: point)
                                        //                                                        }
                                        //                                                    }
                                        //                                                }
                                        //                                                .animation(.easeInOut, value: vm.selectedEventPoint)
                                        //                                            }
                                        //                                        }
                                        //                                        Spacer()
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 3 / 5)
                            VStack{
                                
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
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .environmentObject(vm)
        .task{
            vm.saveAction = {
                if let crew = vm.selectedCrew{
                    crew.updateWithValues(x: vm.coordinateX,
                                          y: vm.coordinateY,
                                          rotation: Double(vm.rotation),
                                          scaleFactor: vm.scaleFactor,
                                          position: vm.position,
                                          isRequired: true,
                                          in: dataManager.mainContext)
                }
            }
        }
        .onAppear {
            appState.primaryAction = {
                
            }
            appState.secondaryAction = {
                
            }
            appState.stepBackAction = {
                
            }
        }
    }
}

#Preview {
    let dm = DataManager(globalDataManager: NetworkManager())
    let appState = ApplicationState()
    let settings = GlobalSettings()
    dm.networkManager.eventProgressHandler = appState
    dm.networkManager.globalSettingsDelegate = settings
    let obvan = Obvan(context: dm.mainContext)
    return AddEditObvanView(obvan: obvan)
        .environmentObject(settings)
        .environmentObject(SessionManager())
        .environmentObject(appState)
        .environmentObject(Router())
        .environmentObject(dm)
        .environment(\.managedObjectContext, dm.mainContext)

}
