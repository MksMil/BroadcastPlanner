import SwiftUI

struct PointEditTextCellView: View {

    let optic: OpticType
    
    var body: some View {
        Text(optic.rawValue)
            .font(.system(size: 40))
            .bold()
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .allowsTightening(true)
            .truncationMode(.middle)
            .multilineTextAlignment(.center)
            .padding(5)
    }
}

