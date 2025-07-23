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
    var selectedPhoto: PhotosPickerItem? {
        willSet{
            Task{
                guard let item = newValue,
                      let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data)
                else { return }
                self.uiimage = image
            }
        }
    }
    
    var uiimage: UIImage?{
        willSet{
            if let newValue{
                //update SKScene background
                renderObvanScene.backImage = newValue
                
            }
        }
    }
    
    var coordinateX: Double = 0
    var coordinateY: Double = 0
    var rotation: Int = 0
    var scaleFactor: Double = 0
    var position: String = ""
    
    @Published var selectedCrew: ObvanTemplateCrew?
    @Published var isEdit: Bool = false
    //filter?
    
    let obvan: Obvan
    var templateCrews: [ObvanTemplateCrew] = []
    let renderObvanScene: ObvanEditSpriteScene
    var saveAction: (()->())?
    
    
    init(obvan: Obvan){
        self.obvan = obvan
        self.renderObvanScene = ObvanEditSpriteScene()
        self.renderObvanScene.crewDelegate = self
        self.templateCrews = obvan.viewTemplateCrews
        self.uiimage = obvan.image?.makeUIImage()
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
//        if let selectedCrew {
            templateCrews.removeAll { crew in
                crewToDelete.viewId == crew.viewId
//            }
        }
        isEdit = false
        selectedCrew = nil
    }
    func selectTemplateObvanCrew(_ obvanCrew: ObvanTemplateCrew){
        selectedCrew = obvanCrew
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
        print("crew selected")
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
