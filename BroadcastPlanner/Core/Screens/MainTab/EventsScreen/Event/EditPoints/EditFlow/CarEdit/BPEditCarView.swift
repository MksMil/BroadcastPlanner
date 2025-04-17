import SpriteKit
import SwiftUI


final class BPEditCarViewModel: ObservableObject {
    
    var renderCarScene: CarEditSpriteScene
    
    @Published var selectedUnit: LocalUnit?
    
    var localUnits: [LocalUnit] = []
    var isEdit: Bool = false
    
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

// MARK: - Points Managment
extension BPEditCarViewModel{
    func addUnit(unit: LocalUnit, image: UIImage?){
        localUnits.append(unit)
//        renderCarScene.updateScene()
        renderCarScene.addUnit(id: unit.viewId, image: image ?? UIImage(), select: true)
        selectedUnit = unit
        isEdit = true
    }
    
    func deletePoint(){
//        renderCarScene.removeSelectedPoint()
//        if let selectedEventPoint {
//            localPoints.removeAll { pointToDelete in
//                pointToDelete.viewId == selectedEventPoint.viewId
//            }
//            filterPointsWithCase(stadiumFilter)
//        }
//        isEdit = false
//        selectedEventPoint = nil
    }
    
    func save(){
//        renderCarScene.saveSelectedPoint()
//        selectedEventPoint = nil
//        isEdit = false
    }
    
    func selectPoint(point: LocalLocationPoint){
//        selectedEventPoint = point
//        renderCarScene.select(point: point)
//        isEdit = true
    }
    
    func updatePoint(_ point: LocalLocationPoint){
//        filterPointsWithCase(stadiumFilter)
//        renderCarScene.updateSpritesWithPoint(point: point)
    }
}

// MARK: - BPSKViewDelegate
extension BPEditCarViewModel: BPSKViewDelegate{
    func selectPointWithId(_ id: String){
//        selectedEventPoint = localPoints.first(where: {$0.viewId == id})
    }
    
    func deselectPoint(){
//        if selectedEventPoint != nil {
//            self.selectedEventPoint = nil
//        }
//        isEdit = false
    }
    
    func deselectPointForRender(){
//        if selectedEventPoint != nil {
//            self.selectedEventPoint = nil
//            renderPitchScene.deselect()
//        }
//        isEdit = false
    }
    //id?
    
    func updatePoint(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?){
//        if let x {
//            coordinateX = x
//        }
//        if let y {
//            coordinateY = y
//        }
//        if let rotation {
//            self.rotation = Int(rotation)
//        }
//        if let scaleFactor {
//            self.scaleFactor = scaleFactor
//        }
        saveAction()
    }
    
    func saveAction(){
//        if let savePointAction {
//            savePointAction()
//        }
    }
}

// MARK: - Scaling scenes
extension BPEditCarViewModel {
    func scaleUp(){
        renderCarScene.scaleUp()
    }
    
    func scaleDown(){
        renderCarScene.scaleDown()
    }
    
    func resetScale(){
        renderCarScene.resetScale()
    }
    
}

// MARK: - Control (move,scale,rotate) Points in Car Edit Scene
extension BPEditCarViewModel{
    func moveUp(){
        renderCarScene.moveUP()
    }
    
    func moveDown(){
        renderCarScene.moveDown()
    }
    
    func moveLeft(){
        renderCarScene.moveLeft()
    }
    
    func moveRight(){
        renderCarScene.moveRight()
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
    
    func changeObvan(car: LocalObvan){
        
    }
}


struct BPEditCarView: View {

    @EnvironmentObject var settings: GlobalSettings
    @EnvironmentObject var mdm: MainDataManager
    @EnvironmentObject var eventRouter: EventTabRouter

    @StateObject var vm: BPEditCarViewModel
    let event: LocalEvent

    @FetchRequest<LocalObvan>(sortDescriptors: []) var obvans

    @State private var isConfirmDiscardChanges: Bool = false

    //if user cant edit(he is not owner)
    var editable: Bool

    @State var obvanTitle: String = "choose car"
    @State private var selectedUnit: LocalUnit?
  
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
                    Menu {
                        ScrollView {
                            ForEach(obvans) { obvan in
                                Text(obvan.viewName)
                                //styling
                                    .onTapGesture {
                                        vm.changeObvan(car: obvan)
                                    }
                            }
                        
//                            ForEach(broadcasters) { bc in
//                                Button("\(bc.viewTitle)") {
//                                    broadcasterTitle = bc.viewTitle
//                                    //vm.updateScene()
//                                }
//                            }
//                            Button("+ new broadcaster") {
//                                // TODO: add broadcaster flow
//                                print("add new broadcaster car")
//                            }
                        }
                    } label: {
                        Text(obvanTitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background {
                                RoundedRectangle(cornerRadius: 5).fill(
                                    .white.opacity(0.4)
                                )
                            }
                    }
                }
                // TODO: Selecte broadcaster & car fsc view
 
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
                        let unit = mdm.createUnitWithUser(user, andSpecialization: specialization, andHardware: hardware, inEvent: event)
//                        let id = unit.viewId
                        var image = UIImage(systemName: "person")
                        if let uiimage = user.image?.makeUIImage(){
                            image = uiimage
                        }
                        vm.addUnit(unit: unit, image: image )
                    }, removeUnitAction: { unitToRemove in
                        mdm.removeUnit(unitToRemove)
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
//                        TaskDescriptionView(text: vm.selectedCarPoint?.viewTask ?? "Task", isEditMode: true)
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
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: LocalEvent.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.moc) {
        let newEvent = LocalEvent(context: lm.moc)
        newEvent.id = "id"
        return newEvent
    }

    return BPEditCarView(
        event: localEvent, editable: true
    )
    .environmentObject(mdm)
    .environment(\.managedObjectContext, mdm.localDataManager.moc)
}
