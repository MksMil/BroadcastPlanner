import SwiftUI

struct PointEditTextCellView: View {

    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 40))
            .bold()
            .lineLimit(3)
            .minimumScaleFactor(0.2)
            .allowsTightening(true)
            .truncationMode(.middle)
            .multilineTextAlignment(.center)
            .padding(5)
    }
}

