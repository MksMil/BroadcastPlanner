import SwiftUI

struct PointPanelCell: View {
    enum PointPanelCellState {
        case selected //visible
        case unselected // 0.5 visible
        case noSelection // all cells visible
    }
    
    let size: Double
    let state: PointPanelCellState
    let number: Int
    
    let isCamera: Bool
    let isSound: Bool
    let isLight: Bool
    let isUser: Bool

    @Binding var selectedPoint: LocationPoint?
    
    var body: some View {
        
        ZStack{
            //camera image
            //video.fill
            //video.slash.fill
            Image(systemName: "video")
                .resizable()
                .renderingMode(.template)
                .frame(width: size / 5, height: size / 5)
                .offset(x: -size * 1 / 3, y: -size * 1 / 3.5)
                .opacity(isCamera ? 1: 0.1)
                
            //sound image
            //speaker.circle.fill
            //speaker.slash.circle.fill
            Image(systemName: "speaker.circle")
                .resizable()
                .renderingMode(.template)
                .frame(width: size / 5, height: size / 5)
                .offset(x: -size * 1 / 3, y: size * 1 / 3.5)
                .opacity(isSound ? 1: 0.1)
            
            //light image
            //lightbulb.fill
            //lightbulb.slash
            Image("light1")
                .resizable()
                .renderingMode(.template)
                .frame(width: size / 5, height: size / 5)
                .offset(x: size * 1 / 3, y: -size * 1 / 3.5)
                .opacity(isLight ? 1: 0.1)
            
            //user image
            //person.fill.checkmark
            //person.crop.circle.badge.questionmark
            //person.crop.circle.badge.checkmark
            Image(systemName: "person")
                .resizable()
                .renderingMode(.template)
                .frame(width: size / 5, height: size / 5)
                .offset(x: size * 1 / 3, y: size * 1 / 3.5)
                .opacity(isUser ? 1: 0.1)
            
            //number
            Text(makeNumber())
                .font(.system(size: size / 2.5))
                .bold()
                .frame(width: size / 1.8, height: size / 1.8)
        }
        .frame(width: size, height: size)
        .background {
            RoundedRectangle(cornerRadius: size / 10).fill(.white.opacity(0.4))
        }
        .opacity(state == PointPanelCellState.unselected ? 0.3: 1)
    }
    
    func makeNumber() -> String{
        if number != 0 {
            return "\(number)"
        } else {
            return "-"
        }
    }
}

#Preview {
    PointPanelCell(size:200, state: .selected, number: 20, isCamera: true,isSound: true,isLight: true, isUser: true, selectedPoint: .constant(nil))
}
