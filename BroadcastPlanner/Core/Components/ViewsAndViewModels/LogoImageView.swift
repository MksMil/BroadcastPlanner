import SwiftUI

struct LogoImageView: View {
    
    var image: Image
    var logoSize: Double
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: logoSize, height: logoSize)
            .padding(logoSize / 10)
            .background{
                Circle().fill( .ultraThinMaterial.opacity(0.9))
                    .overlay {
                        Circle().stroke(Color.white, lineWidth: 3)
                    }
            }
    }
}

#Preview {
    ZStack{
        Color.blue
            .ignoresSafeArea()
        LogoImageView(image: Image("Dynamo"), logoSize: 150)
    }
}
