import SwiftUI

struct LogosCellImageView: View {
    
    var homeImageId: String?
    var guestImageId: String?
    let size : Double
    
    var body: some View {
        HStack{
            //home team logo
            ImageWrapper(id: homeImageId, type: .club,imageSize: ImageSizes.mediumImages)
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(size / 10)
                .clipShape(Circle())
                .background{
                    Circle().fill(.white.opacity(0.4))
                }
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 3)
                }
                
            
            ImageWrapper(id: guestImageId,type: .club, imageSize: ImageSizes.mediumImages)
                .scaledToFit()
                .frame(width: size, height: size)
                .padding(size / 10)
                .clipShape(Circle())
                .background{
                    Circle().fill(.white.opacity(0.4))
                }
                .overlay {
                    Circle().stroke(Color.white, lineWidth: 3)
                }
        }
    }
}

