import SwiftUI

struct CellImage: View {
    let image: LocalImage
    var body: some View {
        ImageWrapper(id: image.viewId, type: .venue,imageSize: .mediumImages)
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
