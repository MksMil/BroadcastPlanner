import SwiftUI

struct LogoImageView: View {
    
    var imageString: String
    var logoSize: Double = 75
    var isBackground: Bool = true
    
    var body: some View {
        if isBackground{
            makeImage()
                .scaledToFit()
                .opacity(imageString.isEmpty ? 0.25: 1)
                .frame(width: logoSize, height: logoSize)
                .padding(15)
                .background(
                    Circle().fill( .ultraThinMaterial.opacity(0.9))
                        .overlay {
                            Circle().stroke(Color.white, lineWidth: 3)
                        })
        } else {
            makeImage()
                .scaledToFit()
                .opacity(imageString.isEmpty ? 0.25: 1)
                .frame(width: logoSize, height: logoSize)
//                .padding(15)
        }
    }
    
    private func makeImage() -> some View{
        if imageString.isEmpty{
            return Image(systemName: "plus.circle").resizable()
        } else {
        return Image(imageString).resizable()
        }
    }
}

#Preview {
    LogoImageView(imageString: "")
}
