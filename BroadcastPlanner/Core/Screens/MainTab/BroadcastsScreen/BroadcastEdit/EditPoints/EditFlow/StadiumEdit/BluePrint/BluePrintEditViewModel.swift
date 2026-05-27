import UIKit
import SpriteKit
import Combine

@MainActor
protocol BlueprintDataDelegate: AnyObject {
  
  func selectUnitFromRenderer(_ unit: (any BluePrintEditable)?)
  func deselectUnitFromRenderer()
  
  func updateUnit(x: CGFloat,
                  y: CGFloat,
                  scaleFactor: CGFloat,
                  rotation: CGFloat) //x,y,rotation,scaleFactor
}
@MainActor
protocol BluePrintRendererDataSource: AnyObject {
  func unit(for id: String) -> LayoutRenderUnit?
  var units: [LayoutRenderUnit] { get }
  var backgroundImage: UIImage? { get }
}

enum LayoutType: String {
  //aux - rawValue - name for icon in tabbar
  case venue = "sportscourt"
  case obvan = "truck.box.fill"
}
enum LayoutFilter: Codable, Hashable {
    case stadium(BPEventPlanPointStadiumFilter)
    case obvan(BPObvanPositionFilter)
}

class LayoutState: Identifiable, Hashable {
  var id: String
  var lastSelected: LayoutRenderUnit? = nil// for state resume
  var units: [LayoutRenderUnit]
  let layoutType: LayoutType
  var backgroundImage: UIImage?
  var activeFilter: LayoutFilter
  var lastStateScreenshot: UIImage?
  
  init(id: String, units: [LayoutRenderUnit], layoutType: LayoutType, backgroundImage: UIImage? = nil) {
    self.id = id
    self.units = units
    self.layoutType = layoutType
    self.backgroundImage = backgroundImage
    self.activeFilter = layoutType == .venue
                ? .stadium(.all)
                : .obvan(.all)
    self.lastStateScreenshot = backgroundImage
  }
  
  // Hashable
     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
     
     // Equatable — требуется для Hashable
     static func == (lhs: LayoutState, rhs: LayoutState) -> Bool {
         lhs.id == rhs.id
     }
}

@MainActor
final class BluePrintEditViewModel: ObservableObject {
  private enum SelectionSource {
      case vm
      case renderer
  }
  
  let broadcast: Broadcast
  let dataManager: DataManager
  let router: Router
  let renderDelegate: BluePrintRenderDelegate
  let scene: SKScene
  
  //State
  // TODO: bugggs иногда скриншот обвана сохраняется в веньюПревью
  @Published var selectedState: LayoutState? {
    willSet{
      // templateGroup availability
      isTemplateGroupAvailable = newValue?.layoutType == .venue
      selectedState?.lastSelected = selectedUnit
    }
    didSet {
      oldValue?.lastStateScreenshot = makeSceneScreenshot()
      if oldValue?.id != selectedState?.id {
        filterPointsWithCase()
        renderDelegate.updateScene()
        selectedUnit = selectedState?.lastSelected
      }
    }
  }
  @Published var states: [LayoutState] = []
  //Unit
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
  private var lastSelectionSource: SelectionSource = .vm
  
  //Template
  @Published var selectedTemplate: Template?
  
  //view visual state
  @Published var newTemplateName: String = "new template"
  @Published var isTemplateGroupAvailable = true
  @Published var isLoading: Bool = true
  @Published var isDeleteConfirm: Bool = false //confirmation
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
  
  //filter
  @Published var filteredUnits:[LayoutRenderUnit] = []
//  @Published var stadiumFilter: BPEventPlanPointStadiumFilter = .all{
//      didSet{
//          filterPointsWithCase()
//          selectedUnit = nil
//          renderDelegate.updateScene()
//      }
//  }
  
  // MARK: Init
  init(broadcast: Broadcast, dataManager: DataManager, router: Router) {
    self.broadcast = broadcast
    self.dataManager = dataManager
    self.router = router
    let renderer = BluePrintRenderer()
    self.renderDelegate = renderer
    self.scene = renderer
    
    renderer.dataSource = self
    renderer.dataDelegate = self
    Task{ @MainActor in
      await self.setupStates()
      if let state = states.first{
        self.isLoading = false
        selectedState = state          // willSet → renderDelegate.updateScene()
        filterPointsWithCase()
      } else {
        isLoading = false
        renderDelegate.updateScene()   // states пустые — рисуем пустую сцену
      }
    }
  }
}
// MARK: - States managment
extension BluePrintEditViewModel{
  
  func setupStates() async{
    //bg image
    var image: UIImage
    if let cachedImage = await dataManager.getImageWithId(broadcast.venue?.viewSchemaId ?? "", type: .broadcastSchema, size: .originImages){
      image = cachedImage
    } else {
      image = UIImage(named: "stadium") ?? UIImage()
    }
    
    var units: [LayoutRenderUnit] = []
    
    for unit in broadcast.viewVenuePoints{
      let layoutunit = LayoutRenderUnit(
        id: unit.viewId,
        coordinateX: unit.viewX,
        coordinateY: unit.viewY,
        scaleFactor: unit.viewScaleFactor,
        rotation: unit.viewRotation,
        number: unit.viewNumber,
        firstName: unit.member?.viewFirstName ?? "",
        lastName: unit.member?.viewLastName ?? "",
        personId: unit.member?.id,
        camera: unit.camera?.optic,
        sound:  unit.sound?.windDefence,
        soundPlace: unit.sound?.placeType,
        light: unit.light?.lightType,
        hardware: nil,
        task: unit.task,
        description: unit.pointDescription,
        image: await dataManager.getImageWithId(unit.viewMemberId,
                                                type: .member,
                                                size: .smallImages)
      )
      units.append(layoutunit)
    }
    let venueState = LayoutState(id: UUID().uuidString,
                                 units: units,
                                 layoutType: .venue,
                                 backgroundImage: image)
    states.append(venueState)
    if broadcast.venueSchemaPreview == nil {
      dataManager.broadcasts.assignSnapshot(image,
                                            imageType: .venuePreview, toBroadcastObjectID: broadcast.objectID)
    }
    for obvan in broadcast.viewObvans{
      await addObvanState(obvan)
    }
  }
  func clear(){
    if let selectedState {
      selectedUnit = nil
      selectedState.units = []
      filterPointsWithCase()
      renderDelegate.updateScene()
    }
  }
}


//MARK: - BlueprintDataDelegate (update flow from SKScene)
extension BluePrintEditViewModel: BlueprintDataDelegate{
  
  func selectUnitFromRenderer(_ unit: (any BluePrintEditable)?) {
      if let unit = unit as? LayoutRenderUnit {
        lastSelectionSource = .renderer   // помечаем — изменение пришло из сцены
        selectedUnit = unit           // didSet видит .renderer → не трогает сцену
      }
  }

  func deselectUnitFromRenderer() {
      lastSelectionSource = .renderer
      selectedUnit = nil
  }
  
  func updateUnit(x: CGFloat,
                  y: CGFloat,
                  scaleFactor: CGFloat,
                  rotation: CGFloat) {
    
    isSaved = false
    selectedUnit?.coordinateX = x
    selectedUnit?.coordinateY = y
    selectedUnit?.rotation = rotation
    selectedUnit?.scaleFactor = scaleFactor
  }
}

// MARK: - BluePrintRendererDataSource
extension BluePrintEditViewModel: BluePrintRendererDataSource {
    var units: [LayoutRenderUnit] {
         filteredUnits
     }
     var backgroundImage: UIImage? {
         selectedState?.backgroundImage
     }
    func unit(for id: String) -> LayoutRenderUnit? {
      filteredUnits.first { $0.id == id }
    }
}
//MARK: - filter
extension BluePrintEditViewModel{
  
  func filterPointsWithCase() {
      guard let state = selectedState else {
          filteredUnits = []
          return
      }
      switch state.activeFilter {
      case .stadium(let filter):
          filteredUnits = applyStadiumFilter(filter, to: state.units)
      case .obvan(let filter):
          filteredUnits = applyObvanFilter(filter, to: state.units)
      }
  }

  private func applyStadiumFilter(_ filter: BPEventPlanPointStadiumFilter,
                                   to units: [LayoutRenderUnit]) -> [LayoutRenderUnit] {
      switch filter {
        case .all:
          return units
        case .cam:
          return units.filter{$0.camera != nil}
        case .person:
          return units.filter{$0.personId != nil}
        case .mic:
          return units.filter{$0.sound != nil}
        case .light:
          return units.filter{$0.light != nil}
      }
  }

  private func applyObvanFilter(_ filter: BPObvanPositionFilter,
                                 to units: [LayoutRenderUnit]) -> [LayoutRenderUnit] {
    switch filter {
      case .all:       return units
      case .director: return units.filter { ($0.position == "Main director") || ($0.position == "Replay director") || ($0.position == "Director") }
//      case .assistant: return units.filter { ($0.position == "Replay director") || ($0.position == "Director") }
      case .soundDirector:     return units.filter { ($0.position == "Sound director") || ($0.position == "Main sound director") }
      case .graphicEd:     return units.filter { $0.position == "Graphics operator" }
      case .replayOp:     return units.filter {$0.position == "Replay operator" }
    }

  }
  func setStadiumFilter(_ filter: BPEventPlanPointStadiumFilter) {
      selectedState?.activeFilter = .stadium(filter)
      selectedUnit = nil
      filterPointsWithCase()
  }

  func setObvanFilter(_ filter: BPObvanPositionFilter) {
      selectedState?.activeFilter = .obvan(filter)
      selectedUnit = nil
      filterPointsWithCase()
  }
}

//MARK: - Actions
extension BluePrintEditViewModel{
  func addUnit(){
    //data come from outside
    let unit = LayoutRenderUnit(id: UUID().uuidString,
                                coordinateX: 0,
                                coordinateY: 0,
                                scaleFactor: 1,
                                rotation: 0,
                                number: (selectedState?.units.count ?? 0) + 1,
                                personId: nil,
                                camera: nil,
                                sound: nil,
                                soundPlace: nil,
                                light: nil,
                                hardware: nil,
                                task: nil,
                                description: nil)
    isSaved = false
    selectedState?.units.append(unit)
    selectedState?.units.sort { $0.number ?? 0 < $1.number ?? 0 }
    filterPointsWithCase()
    if filteredUnits.contains(unit){
      renderDelegate.addUnit(layoutUnit: unit)
      selectedUnit = unit
    }
  }
  func save() async {
    isSaving = true
    //save flow

    selectedState?.lastStateScreenshot = makeSceneScreenshot()
    //
    dataManager.saveFromStates(states: states,
                               withBroadcastId: broadcast.objectID)
    isSaved = true
    isSaving = false
  }
  
  func delete(){
    if let selectedUnit {
      isSaved = false
      renderDelegate.deleteUnit(id: selectedUnit.id)
      selectedState?.units.removeAll{$0.id == selectedUnit.id}
      filterPointsWithCase()
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
  
  func saveAndGoBack(){
    Task{
      await save()
      router.stepBack()
    }
  }
  
  // MARK: scene screenshot
  func prepareForScreenshot(){
    lastSelectionSource = .vm
    selectedUnit = nil
    renderDelegate.resetScale(immediately: true)
  }
  
    func makeSceneScreenshot()-> UIImage?{
        prepareForScreenshot()
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

// MARK: - Template
extension BluePrintEditViewModel{
  func loadTemplate(template: Template){
    //make units from template
    selectedTemplate = template
    newTemplateName = template.viewName
    var units: [LayoutRenderUnit] = []
    for point in template.viewTemplatePoints{
      let unit = LayoutRenderUnit(id: UUID().uuidString,
                                  coordinateX: point.viewX,
                                  coordinateY: point.viewY,
                                  scaleFactor: CGFloat(point.scaleFactor),
                                  rotation: CGFloat(point.rotation),
                                  number: Int(point.number),
                                  personId: nil,
                                  camera: point.camera ,
                                  sound: nil,
                                  soundPlace: point.sound,
                                  light: point.light,
                                  hardware: nil,
                                  task: point.task,
                                  description: point.description)
      units.append(unit)
    }
    if selectedState?.layoutType != .venue{
      selectedState = states.first{$0.layoutType == .venue}
    }
    if selectedState != nil{
      selectedState?.units = units
      filterPointsWithCase()
      renderDelegate.updateScene()
    }
    
    
    //remove new units to state.units
  }
  func saveTemplateWithName(_ name: String) async{
    //make template from state
    //save template to db & netwotk
    if selectedState?.layoutType != .venue{
      selectedState = states.first{$0.layoutType == .venue}
    }
    if selectedState != nil{
      selectedState?.units = units
      filterPointsWithCase()
      await dataManager.saveTemplateFromSchema(units: selectedState?.units ?? [], withName: name)
    }
  }
  func deleteTemplate(){
    if let selectedTemplate {
      dataManager.deleteTemplate(template: selectedTemplate)
      clear()
    }
    //remove selected template from db + save context
  }
  
}

// MARK: - Obvan section
extension BluePrintEditViewModel {
  func addObvan(_ obvan: Obvan) {
    isSaved = false
    Task{
     await addObvanState(obvan)
      dataManager.broadcasts.addObvan(withObjectID: obvan.objectID,
                                      toBroadcast: broadcast.objectID)
    }
  }
  func removeObvan(_ obvan: Obvan){
    dataManager.broadcasts.removeObvan(withObjectID: obvan.objectID,
                                       fromBroadcast: broadcast.objectID)
  }
  
  func addObvanState(_ obvan: Obvan) async {
    var image: UIImage
    var units:[LayoutRenderUnit] = []
    if let cachedImage = await dataManager.getImageWithId(obvan.viewImageId, type: .obvan, size: .originImages){
      image = cachedImage
    } else {
      image = UIImage(named: "empty_obvan") ?? UIImage()
    }
    let filtered = broadcast.viewCrews.filter { $0.viewObvanId == obvan.viewId }
    
    let templateCrews = obvan.viewTemplateCrews
    
    units = await withTaskGroup(of: LayoutRenderUnit.self) { group in
        for crew in filtered {
            group.addTask {
              let image = await self.dataManager.getImageWithId(
                    crew.viewMemberId,
                    type: .member,
                    size: .smallImages
                )
                return LayoutRenderUnit(
                    id: crew.viewId,
                    coordinateX: crew.viewX,
                    coordinateY: crew.viewY,
                    scaleFactor: crew.viewScaleFactor,
                    rotation: crew.viewRotation,
                    
                    number: nil,
                    position: crew.position,
                    firstName: crew.member?.viewFirstName ?? "",
                    lastName: crew.member?.viewLastName ?? "",
                    personId: crew.member?.id,
                    camera: nil,
                    sound:  nil,
                    soundPlace: nil,
                    light: nil,
                    hardware: crew.hardware?.type,
                    task: crew.task,
                    description: crew.description,
                    image: image
                )
            }
        }
        var collected: [LayoutRenderUnit] = []
        for await unit in group {
            collected.append(unit)
        }
        return collected
    }
    let obvanState = LayoutState(id: obvan.viewId,
                                 units: units,
                                 layoutType: .obvan,
                                 backgroundImage: image)
    states.append(obvanState)
  }
}
