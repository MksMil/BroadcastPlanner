import SpriteKit
import SwiftUI


final class BPEditCarViewModel: ObservableObject {
    
    var renderCarScene = SKScene()
    
    @Published var selectedCarPoint: LocalObvanUnit?
    init(event: LocalEvent) {
        self.renderCarScene = CarEditSpriteScene()
    }
    
    // MARK: scene screenshot
    func makeSceneScreenshot()-> UIImage?{
        guard let view = renderCarScene.view else {
            print("Сцена не привязана к SKView.")
            return nil
        }
        
        guard let texture = view.texture(from: renderCarScene) else {
            print("Не удалось создать текстуру из сцены.")
            return nil
        }
        
        let size = CGSize(width: texture.size().width, height: texture.size().height)
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        UIImage(cgImage: texture.cgImage()).draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
// MARK: - Scaling scenes
extension BPEditCarViewModel {
    func scaleUp(){
//        renderCarScene.scaleUp()
    }
    
    func scaleDown(){
//        renderCarScene.scaleDown()
    }
    
    func resetScale(){
//        renderCarScene.resetScale()
    }
    
}

// MARK: - Control (move,scale,rotate) Points in Car Edit Scene
extension BPEditCarViewModel{
    func moveUp(){
//        renderCarScene.moveUP()
    }
    
    func moveDown(){
//        renderCarScene.moveDown()
    }
    
    func moveLeft(){
//        renderCarScene.moveLeft()
    }
    
    func moveRight(){
//        renderCarScene.moveRight()
    }
    
    func rotateCounterClockwise(){
//        renderCarScene.rotateCounterClockwiseSelectedPointCameraNode()
    }
    
    func rotateClockwise(){
//        renderCarScene.rotateClockwiseSelectedPointCameraNode()
    }
    
    func swap(){
//        renderCarScene.swapSelectedPointCameraNode()
    }
    
    func scaleUpPoint(){
//        renderCarScene.scaleUpSelectedPoint()
    }
    
    func scaleDownPoint(){
//        renderCarScene.scaleDownSelectedPoint()
    }
    
}


struct BPEditCarView: View {

    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var mdm: MainDataManager
    @EnvironmentObject var eventRouter: EventTabRouter

    @StateObject var vm: BPEditCarViewModel
    let event: LocalEvent

    @FetchRequest<LocalBroadcaster>(sortDescriptors: []) var broadcasters

    @State private var isConfirmDiscardChanges: Bool = false

    //if user cant edit(he is not owner)
    var editable: Bool

    @State var broadcasterTitle: String = "choose broadcaster"
    @State var carTitle: String = "choose car"
    @State private var selectedUnit: LocalObvanUnit?
  
    init(event: LocalEvent, editable: Bool) {
        self.event = event
        self.editable = editable
        self._vm = .init(wrappedValue: BPEditCarViewModel(event: event))
    }

    var body: some View {
        ZStack {
            MainBackground()
            VStack {
                ConfirmationButtonGroupView(isAcceptDisabled: false) {
                    //rollback
                    eventRouter.routeStepBack()
                } acceptAction: {
                    //save
                    eventRouter.routeStepBack()
                } content: {
                    Spacer()
                }
                
                // TODO: Selecte broadcaster & car fsc view
//                Menu {
//                    ScrollView {
//                        ForEach(broadcasters) { bc in
//                            Button("\(bc.viewTitle)") {
//                                broadcasterTitle = bc.viewTitle
//                            }
//                        }
//                        Button("+ new broadcaster") {
//                            // TODO: add broadcaster flow
//                            print("add new broadcaster")
//                        }
//                    }
//                } label: {
//                    Text(broadcasterTitle)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 45)
//                        .background {
//                            RoundedRectangle(cornerRadius: 10).fill(
//                                .white.opacity(0.4)
//                            )
//                        }
//                }
//                .padding(.horizontal, 25)
//                
//                //templates choise
//                if editable {
//                    HStack {
//                        Menu {
//                            
//                        } label: {
//                            Text(carTitle)
//                                .frame(maxWidth: .infinity)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 10).fill(
//                                        .white.opacity(0.4)
//                                    )
//                                    .frame(height: 45)
//                                }
//                        }
//                        .padding(.horizontal, 65)
//                    }
//                    .padding(.vertical, 10)
//                }
                //SKView
                
                
                SpriteView(
                    scene: vm.renderCarScene,
                    debugOptions: [.showsFPS, .showsNodeCount]
                )
                .aspectRatio(2.3, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                HStack(alignment: .top){
                    StaffPanelView(event: event,
                                   addUnitAction: { user,specialization,hardware in
                        let _ = mdm.createNewObvanUnitWithUser(user, andSpecialization: specialization, andHardware: hardware, inEvent: event)

                        
                    }, removeUnitAction: { unitToRemove in

                        mdm.removeObvanUnit(unitToRemove)
                    }, editUnitAction: {
                        
                    })
                    .background{
                        RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.4))
                    }
                    Spacer()
                    VStack{
                        BPEditEventControlPanel(scaleUpAction: {/*vm.scaleUp()*/},
                                                scaleDownAction: {/*vm.scaleDown()*/},
                                                resetScaleAction: {/*vm.resetScale()*/})
                        
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
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.4), lineWidth: 2)
                        }
                        // Task managment
                        TaskDescriptionView(text: vm.selectedCarPoint?.viewTask ?? "Task", isEditMode: true)
                        //                        .disabled(vm.selectedEventPoint == nil)
                        //                        .opacity(vm.selectedEventPoint == nil ? 0.6 : 1)
                        
                    }
                    .padding(5)
                    .frame(width: 140)
                }
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .padding(.horizontal)
        }
    }

   
}

#Preview {
    let mdm = MainDataManager(
        localDataManager: DataManager(), globalDataManager: NetworkManager(),
        userId: "123")

    return BPEditCarView(
        event: mdm.localDataManager.fetchOrCreateEventWithId(
            "123", inContext: .main), editable: true
    )
    .environmentObject(mdm)
    .environment(\.managedObjectContext, mdm.localDataManager.moc)
}
