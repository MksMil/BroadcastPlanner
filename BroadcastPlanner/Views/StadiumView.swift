import SwiftUI

struct StadiumView: View {
    
    @EnvironmentObject var storage:Storage
    
    var body: some View {
        //just a plceholder for a stadium
        GeometryReader{ geo in
            let camH = geo.size.height / 10.0
            let camW = geo.size.width / 10.0
            
            ZStack{
                Section{
                    //outer
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray/*.shadow(.inner(radius: 10))*/)
                        .frame(width: geo.size.width, height: camH * 4)
                        .shadow(radius: 10)
                    
                    //inner
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.shadow(.inner(radius: 3)))
                        .frame(width: camW * 8,height: camH * 3)
                    
                    //field
                    Section{
                        Rectangle()
                            .fill(.green.shadow(.inner(radius: 2)))
                            .frame(width: camW * 5, height: camH * 2)
                        Circle()
                            .stroke(lineWidth: 2)
                            .frame(width: camH / 2)
                            .foregroundStyle(Color.white)
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW * 2, height: camH * 1.8)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: camW, height: 0))
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW * 2, height: camH * 1.8)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: -camW, height: 0))
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW * 0.8 , height: camH * 1.0)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: -camW * 1.6, height: 0))
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW * 0.8 , height: camH * 1.0)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: camW * 1.6, height: 0))
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW / 8 , height: camH * 0.3)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: -camW * 2.06, height: 0))
                        Rectangle()
                            .stroke(lineWidth: 2)
                            .frame(width: camW / 8 , height: camH * 0.3)
                            .foregroundStyle(.white)
                            .offset(CGSize(width: camW * 2.06, height: 0))
                    }
                }
//                .onTapGesture {
//                    storage.deselect()
//                }
                
                //cameras
                ForEach(storage.cameras) { cam in
                    Button(action: {
                        storage.select(cam: cam)
                    }, label: {
                        CameraView(camera: cam)
                    })
                    .offset(cam.makeOffset(camH: camH,camW: camW))
                        .zIndex(1.0)
                }
            }
            
        }
    }
}

#Preview {
    StadiumView().environmentObject(Storage(cameras: MockData.sampleCameras))

}
