import SpriteKit
import _PhotosUI_SwiftUI
import UIKit
import Combine

@MainActor
class AddEditObvanViewModel: ObservableObject{
  private enum SelectionSource {
      case vm
      case renderer
  }
  
  @Published var selectedPhoto: PhotosPickerItem?{
    didSet{
      Task{
          guard let item = selectedPhoto,
                let data = try? await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
          else { return }
          
          uiimage = image
          
          await dataManager.updateImageWith(uiimage: image, id: obvan.viewId , type: .obvan, lastUpdated: .now)
      }
    }
  }
  @Published var uiimage: UIImage? {
    didSet{
      isSaved = false
      renderDelegate.updateScene()
    }
  }
  
  let obvan: Obvan
  let dataManager: DataManager
  let router: Router
  let settings: GlobalSettings
  let renderDelegate: BluePrintRenderDelegate
  let scene: SKScene

  private var lastSelectionSource: SelectionSource = .vm
  @Published var selectedUnit: LayoutRenderUnit?{
    didSet {
      // Изменение пришло из VM (например, тап в списке)
      // — нужно обновить сцену
      guard lastSelectionSource == .vm else {
        lastSelectionSource = .vm  // сбрасываем для следующего раза
        return
      }
      renderDelegate.deselectUnitToRenderer()
      if let unit = selectedUnit {
        renderDelegate.selectUnitToRenderer(id: unit.id)
      }
    }
  }
  
  @Published var isLoading: Bool = true
  @Published var isDeleteConfirm: Bool = false //confirmation
  @Published var isRemoveCrew: Bool = false
  @Published var isSaving: Bool = false // progressView on saveButton
  @Published var isSaved: Bool = true
  @Published var isConfirmDiscardChangesOrSave: Bool = false //step backconfirmation
  @Published var isEdit: Bool = false {
    didSet{
      if !isEdit{
        isSaved = false
        renderDelegate.updateScene()
        if let id = selectedUnit?.id{
          renderDelegate.selectUnitToRenderer(id: id)
        }
      }
    }
  }
  @Published var isAddObvanSheetShow: Bool = false
  @Published var obvanName: String = ""{
    didSet{
      isSaved = false
    }
  }
  @Published var broadcaster: String = ""{
    didSet{
      isSaved = false
    }
  }
  
  @Published var renderUnits: [LayoutRenderUnit] = []
  @Published var positions: [String]
  var templateCrews: [ObvanTemplateCrew] = []{
    didSet{
      //            sortCrews()
    }
  }
    
  init(obvan: Obvan?,
       dataManager: DataManager,
       router: Router,
       settings: GlobalSettings){
    self.dataManager = dataManager
    if let obvan {
      self.obvan = obvan
    } else {
      let context = dataManager.stack.mainContext
      self.obvan = Obvan(context: context)
      self.obvan.id = UUID().uuidString
    }
    self.router = router
    self.settings = settings
    self.positions = settings.userSpecialization
    let renderer = BluePrintRenderer()
    self.renderDelegate = renderer
    self.scene = renderer
    
    renderer.dataSource = self
    renderer.dataDelegate = self
    
    setup()
    isSaved = true
  }
  
  func setup(){
    obvanName = obvan.viewName.isEmpty ? "" : obvan.viewName
    broadcaster = obvan.viewBroadcasterName.isEmpty ? "" : obvan.viewBroadcasterName
    
    let crews = obvan.viewTemplateCrews
    var units: [LayoutRenderUnit] = []
    for crew in crews {
      units.append(LayoutRenderUnit(id: UUID().uuidString,
                                    coordinateX: crew.viewX,
                                    coordinateY: crew.viewY,
                                    scaleFactor: crew.viewScaleFactor,
                                    rotation: CGFloat(crew.rotation),
                                    number: nil,
                                    personId: UUID().uuidString,
                                    camera: nil,
                                    sound: nil,
                                    soundPlace: nil,
                                    light: nil,
                                    hardware: nil,
                                    task: nil,
                                    description: crew.viewPosition))
        }
    Task{
      if let image = await dataManager.getImageWithId(obvan.viewImageId, type: .obvan, size: .originImages){
        self.uiimage = image
        self.isSaved = true
      }
      renderUnits = units
      renderDelegate.updateScene()
    }
    
  }
}


//MARK: - Actions
extension AddEditObvanViewModel{
  func addUnit(){
    //data come from outside
    let unit = LayoutRenderUnit(id: UUID().uuidString,
                                coordinateX: 0,
                                coordinateY: 0,
                                scaleFactor: 1,
                                rotation: 0,
                                number: nil,
                                personId: UUID().uuidString,
                                camera: nil,
                                sound: nil,
                                soundPlace: nil,
                                light: nil,
                                hardware: nil,
                                task: nil,
                                description: "Unknown")
    isSaved = false
    renderUnits.append(unit)
    renderDelegate.addUnit(layoutUnit: unit)
    selectedUnit = unit
  }
  func setPosition(_ position: String?){
    selectedUnit?.description = position
  }
  func removeObvan(){
    Task{
      await dataManager.removeObvan(obvan)
      router.stepBack()
    }
  }
  
  func save() async {
    isSaving = true
    //save flow
    //
    obvan.name = obvanName
    obvan.broadcaster = broadcaster
    
      await dataManager.updateObvanTemplateCrews(obvan: obvan, units: renderUnits, image: uiimage)
      isSaved = true
      isSaving = false
    
  }
  
  func delete(){
    if let selectedUnit {
      isSaved = false
      renderDelegate.deleteUnit(id: selectedUnit.id)
      renderUnits.removeAll{$0.id == selectedUnit.id}
      self.selectedUnit = nil
    }
  }
  
  func goBack(){
    if isSaved{
      router.stepBack()
    } else {
      isConfirmDiscardChangesOrSave = true
    }
  }
  
  func discardChangesAndGoBack(){
    dataManager.rollBackMoc()
    router.stepBack()
  }
  
  func saveAndGoBack() async {
    await save()
    router.stepBack()
  }
  
  // MARK: scene screenshot
    func makeSceneScreenshot()-> UIImage?{
        guard let view = scene.view else {
                print("Сцена не привязана к SKView.")
                return nil
            }

            guard let texture = view.texture(from: scene) else {
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



// MARK: - BluePrintRendererDataSource
extension AddEditObvanViewModel: BluePrintRendererDataSource{
  func unit(for id: String) -> LayoutRenderUnit? {
    renderUnits.first { $0.id == id }
  }
  
  var units: [LayoutRenderUnit] {
    renderUnits
  }
  
  var backgroundImage: UIImage? {
    uiimage
  }
}

// MARK: - BlueprintDataDelegate
extension AddEditObvanViewModel: BlueprintDataDelegate {
  func selectUnitFromRenderer(_ unit: (any BluePrintEditable)?) {
    if let selected = unit as? LayoutRenderUnit{
      lastSelectionSource = .renderer
      selectedUnit = selected
    }
  }
  
  func deselectUnitFromRenderer() {
    lastSelectionSource = .renderer
    selectedUnit = nil
  }
  
  func updateUnit(x: CGFloat, y: CGFloat, scaleFactor: CGFloat, rotation: CGFloat) {
    isSaved = false
    selectedUnit?.coordinateX = x
    selectedUnit?.coordinateY = y
    selectedUnit?.scaleFactor = scaleFactor
    selectedUnit?.rotation = rotation
  }
  
  
}
