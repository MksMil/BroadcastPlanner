import SwiftUI

struct CellImage: View {
    let image: LocalImage
    var body: some View {
        image.mediumImage
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
