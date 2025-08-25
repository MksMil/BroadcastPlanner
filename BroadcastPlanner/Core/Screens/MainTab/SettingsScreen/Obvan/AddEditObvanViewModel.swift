import SpriteKit
import _PhotosUI_SwiftUI
import UIKit
import Combine


protocol ObvanEditDelegate: AnyObject {
    func selectCrewtWithId(_ id: String)
    func deselectCrew() //id?
    func saveCrewAction()
    func updateTemplateCrew(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?) //x,y,rotation,scaleFactor
}


class AddEditObvanViewModel: ObservableObject{
    @Published var selectedPhoto: PhotosPickerItem? 
    
    @Published var uiimage: UIImage?

    var source: [String] = [] {
        didSet{
            sortCrews()
        }
    }
    var coordinateX: Double = 0
    var coordinateY: Double = 0
    var rotation: Int = 0
    var scaleFactor: Double = 0
    @Published var title: String = ""
    
    @Published var selectedCrew: ObvanTemplateCrew?
    @Published var isEdit: Bool = false
    //filter?
    
    let obvan: Obvan
    var templateCrews: [ObvanTemplateCrew] = []{
        didSet{
            sortCrews()
        }
    }
    //TODO: remove settings dependency aka settiings.sortSource(...)->[newArray] and use it in view
    @Published var sortedCrews: [ObvanTemplateCrew] = []
    let renderObvanScene: ObvanEditSpriteScene
    var saveAction: (()->())?
    func sortCrews(){
        sortedCrews = templateCrews.sorted { first, second in
            source.lastIndex(of: first.viewPosition) ?? 0 < source.lastIndex(of: second.viewPosition) ?? 0
        }
    }
    
    init(obvan: Obvan){
        self.obvan = obvan
        self.renderObvanScene = ObvanEditSpriteScene()
        self.renderObvanScene.crewDelegate = self
        self.templateCrews = obvan.viewTemplateCrews
        self.renderObvanScene.crews = templateCrews
        self.title = obvan.viewName
    }
    
    @MainActor
    func updateImage( uiimage: UIImage?){
        if let uiimage{
            self.uiimage = uiimage
            self.renderObvanScene.backImage = uiimage
        }
    }
    
    // MARK: scene screenshot
    func makeSceneScreenshot()-> UIImage?{
        guard let view = renderObvanScene.view else {
                print("Сцена не привязана к SKView.")
                return nil
            }
            
            guard let texture = view.texture(from: renderObvanScene) else {
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
// MARK: - TemplateObvanCrew managment
extension AddEditObvanViewModel {
    @MainActor
    func addObvanTemplateCrew(_ obvanCrew: ObvanTemplateCrew){
        templateCrews.append(obvanCrew)
        renderObvanScene.addCrew(obvanCrew, select: true)
        selectedCrew = obvanCrew
        renderObvanScene.updateCameraWithNewNode()
        isEdit = true
    }
    
    func deleteObvanTemplateCrew(_ crewToDelete: ObvanTemplateCrew){
        renderObvanScene.removeSelectedCrew()
            templateCrews.removeAll { crew in
                crewToDelete.viewId == crew.viewId
        }
        isEdit = false
        selectedCrew = nil
    }
    func selectTemplateObvanCrew(_ obvanCrew: ObvanTemplateCrew){
        selectedCrew = obvanCrew
        coordinateX = obvanCrew.viewX
        coordinateY = obvanCrew.viewY
        rotation = Int(obvanCrew.viewRotation)
        scaleFactor = obvanCrew.viewScaleFactor
        renderObvanScene.select(crew: obvanCrew)
        isEdit = true
    }
    
    func deselect(){
        renderObvanScene.deselect()
        selectedCrew = nil
        isEdit = false
    }
}
// MARK: - ObvanEditDelegate
extension AddEditObvanViewModel: ObvanEditDelegate{
    func saveCrewAction() {
       saveAction?()
    }
    
    func selectCrewtWithId(_ id: String) {
        selectedCrew = templateCrews.first(where: {$0.viewId == id})
        isEdit = true
    }
    
    func deselectCrew() {
        if selectedCrew != nil {
            saveAction?()
            selectedCrew = nil
        }
        isEdit = false
    }
    
    func deselectCrewForRenderer() {
        if selectedCrew != nil {
            saveAction?()
            selectedCrew = nil
            renderObvanScene.deselect()
        }
        isEdit = false
    }
    
    func updateTemplateCrew(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?) {
        if let x {
            coordinateX = x
        }
        if let y {
            coordinateY = y
        }
        if let rotation {
            self.rotation = Int(rotation)
        }
        if let scaleFactor {
            self.scaleFactor = scaleFactor
        }
        saveAction?()
    }
}

// MARK: - Scaling scenes
extension AddEditObvanViewModel {
    func scaleUp(){
        renderObvanScene.scaleUp()
    }
    
    func scaleDown(){
        renderObvanScene.scaleDown()
    }
    
    func resetScale(){
        renderObvanScene.resetScale()
    }
}

// MARK: - Control (move,scale,rotate) TemplateCrew in Obvan Edit Scene
extension AddEditObvanViewModel{
    func moveUp(){
        renderObvanScene.moveUP()
    }
    
    func moveDown(){
        renderObvanScene.moveDown()
    }
    
    func moveLeft(){
        renderObvanScene.moveLeft()
    }
    
    func moveRight(){
        renderObvanScene.moveRight()
    }
    
    func rotateCounterClockwise(){
        renderObvanScene.rotateCounterClockwiseSelectedPointCameraNode()
    }
    
    func rotateClockwise(){
        renderObvanScene.rotateClockwiseSelectedPointCameraNode()
    }
    
    func swap(){
        renderObvanScene.swapSelectedPointCameraNode()
    }
    
    func scaleUpPoint(){
        renderObvanScene.scaleUpSelectedPoint()
    }
    
    func scaleDownPoint(){
        renderObvanScene.scaleDownSelectedPoint()
    }
    
}
