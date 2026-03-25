import SpriteKit

extension SKNode{
    func isNotNodeWithName(_ name: String)->Bool{
        return self.name != name
    }
}
