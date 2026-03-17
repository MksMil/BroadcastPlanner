protocol BPSKViewDelegate: AnyObject {
    func selectPointWithId(_ id: String)
    func deselectPoint() //id?
    func saveAction()
    func updatePoint(x: Double?, y: Double?, rotation: Double?, scaleFactor: Double?) //x,y,rotation,scaleFactor
}
