import SwiftUI

struct CameraView: View {
    
   @ObservedObject var camera: Camera
    
    var camH: Double = 10
    var camW: Double = 20
    
    var body: some View {
       
            Image(systemName: "video.fill")
                .resizable()
                .frame(width:  camW, height: camH)
                .foregroundStyle(camera.selected ? .orange : .black)
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(radians: camera.direction.directionMultiplier))
               
//                        .overlay {
//                            Text(camera.number)
//                                .foregroundStyle(.white)
//                                .offset(makeTextOffset(cam: camera))
//                        }
        
    }
    func makeTextOffset(cam: Camera) -> CGSize{
        switch cam.direction {
        case .up:
            CGSize(width: 0, height: camW / 6)
        case .down:
            CGSize(width: 0, height: -camW / 6)
        case .left:
            CGSize(width: camH / 6, height: 0)
        case .right:
            CGSize(width: -camH / 6, height: 0)
        default: CGSize.zero
        }
    }
}

#Preview {
    CameraView(camera: Camera(position: .mainMatch))
}
