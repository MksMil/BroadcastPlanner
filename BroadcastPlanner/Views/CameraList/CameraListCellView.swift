import SwiftUI

struct CameraListCellView: View {
    
    var camera: Camera
    
    var body: some View {

            RoundedRectangle(cornerRadius: 8)
                .fill(.gray)
                .opacity(0.3)
                .frame(height: 70)
                .overlay {
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                            .frame( height: 70)
                            .background {
                                Color.clear
                            }
                        HStack{
                            camera.cameraMan.image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal)
                            
                            VStack{
                                Text(camera.cameraMan.name )
                                    .font(.title)
                                    .bold()
                                Text(camera.position.rawValue)
                                    .font(.subheadline)
                                    .italic()
                            }
                        }
                    }
                }
    }
}

#Preview {
    CameraListCellView(camera: Camera(position: .dressingRoom))
}
