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
//            ScrollView{
                VStack(spacing: 0){
                    
                    //scscene
                    SpriteView(scene: vm.renderObvanScene,
                               debugOptions: [.showsFPS,.showsNodeCount])
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 5).stroke( Color.black)
                    })
                    .padding(.horizontal)
                    
                    GeometryReader{ geo in
                        
                        //control panel
                        VStack(spacing: 0){
                            HStack {
                                
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
                                Text(vm.title.isEmpty ? "add name": vm.title)
                                    .font(.system(size: 20))
                                    .foregroundStyle(vm.title.isEmpty ? .secondary: .primary)
                                    .bold()
                                    .minimumScaleFactor(0.3)
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
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
                                    .onTapGesture {
                                        appState.cleanTFInfo()
                                        appState.fieldType = .custom([])
                                        appState.isSecure = false
                                        appState.textfieldSource = vm.title
                                        appState.promptString = "Enter new Title"
                                        appState.openTextFieldWithAction { title in
                                            vm.title = title
                                        }
                                    }
                                
                                ObvanControlPanel(isEdit: $vm.isEdit,
                                                  addAction: {
                                    isEditPressed = true
                                },
                                                  deleteAction: {
                                    if let crewToDelete = vm.selectedCrew{
                                        vm.deleteObvanTemplateCrew(crewToDelete)
                                        dataManager.mainContext.performAndWait{
                                            obvan.removeFromCrewTemplates(crewToDelete)
                                            dataManager.mainContext.delete(crewToDelete)
                                        }
                                    }
                                },
                                                  saveAction: {
                                    if vm.selectedCrew != nil{
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
                            
                            HStack{
                                VStack{
                                    ScrollView{
                                        ForEach(vm.sortedCrews){ crew in
                                            ObvanTemplateCrewCell(crewPosition: crew.viewPosition, isSelected: crew == vm.selectedCrew)
                                                .onTapGesture {
                                                    withAnimation{
                                                        if vm.selectedCrew == crew{
                                                            vm.deselectCrewForRenderer()
                                                        } else {
                                                            vm.selectTemplateObvanCrew(crew)
                                                        }
                                                    }
                                                }
                                                .animation(.easeInOut, value: vm.selectedCrew)
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
            
            .transitionWithOpacity()
//        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden()
        .environmentObject(vm)
        .onAppear {
            Task{
                print("requet for obvan image with id: \(obvan.viewId)")
                if let image = await dataManager.imageCacher.getImage(id: obvan.viewId, size: .originImages){
                    print("get image for obvan")
                    vm.updateImage(uiimage: image)
                } else {
                    print("no image for obvan")
                }
            }
            vm.saveAction = {
                if let crew = vm.selectedCrew{
                    crew.updateWithValues(x: vm.coordinateX,
                                          y: vm.coordinateY,
                                          rotation: Double(vm.rotation),
                                          scaleFactor: vm.scaleFactor,
                                          in: dataManager.mainContext)
                    
                }
            }
            vm.source = globalSettings.userSpecialization
            appState.primaryAction = {
                let lastUpdatedValue = Date.now
                dataManager.mainContext.performAndWait {
                    let image: LocalImage = dataManager.mainContext.fetchOrCreateObject(withID: obvan.viewId)
                        image.updateValues(type: GlobalProperties.ImageType.obvan.rawValue,
                                           lastUpdated: lastUpdatedValue,
                                           in: dataManager.mainContext)
                    obvan.image = image
                    image.addToParentObvan(obvan)
                    try? dataManager.mainContext.save()
                }
                
                //network save
                Task{
                   await dataManager.networkManager.saveData(obvan.dto, withId: obvan.viewId, withType: GlobalProperties.Path.obvans)
                    if let uiimage = vm.uiimage{
                        _ = await dataManager.networkManager.saveImageToGlobalStorage(id: obvan.viewId, uiimage: uiimage, type: GlobalProperties.ImageType.obvan, lastUpdated: lastUpdatedValue)
                    }
                }
                router.stepBack()

            }
            appState.secondaryAction = {
                
            }
            appState.stepBackAction = {
                dataManager.mainContext.rollback()
                router.stepBack()
            }
        }
        .sheet(isPresented: $isEditPressed) {
            List{
                ForEach(globalSettings.userSpecialization, id:\.self){ spec in
                    HStack{
                        Text(spec)
                     Spacer()
                        if spec == vm.selectedCrew?.viewPosition{
                            Image(systemName: "checkmark")
                        }
                    }
                        .onTapGesture {
                            if let crew = vm.selectedCrew{
                                    crew.updateWithValues(position: spec,
                                                          in: dataManager.mainContext)
//                                vm.templateCrews = obvan.viewTemplateCrews
//                                vm.selectedCrew = crew
                            } else {
                                dataManager.mainContext.performAndWait{
                                    let id = UUID().uuidString
                                    let newTemplateCrew: ObvanTemplateCrew = dataManager.mainContext.fetchOrCreateObject(withID: id)
                                    newTemplateCrew.position = spec
                                    obvan.addToCrewTemplates(newTemplateCrew)
                                    vm.addObvanTemplateCrew(newTemplateCrew)
                                    vm.selectedCrew = newTemplateCrew
                                }
                            }
                            vm.sortCrews()
                            isEditPressed = false
                        }
                }
            }
            .presentationDragIndicator(.visible)
            
        }
        .onReceive(vm.$title) { title in
            obvan.name = title
        }
        .onReceive(vm.$selectedPhoto) { newImage in
            Task{
                guard let item = newImage,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { return }
                
                vm.updateImage(uiimage: image)
                await dataManager.updateImageWith(uiimage: image, id: obvan.viewId, type: .obvan, lastUpdated: .now)
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


