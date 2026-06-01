import SwiftUI

struct PointEditTextCellView: View {

    let text: String
    
    var body: some View {
      Text(text)
          .font(.system(size: 20, weight: .semibold))
          .lineLimit(3)
          .minimumScaleFactor(0.3)
          .allowsTightening(true)
          .truncationMode(.middle)
          .multilineTextAlignment(.center)
          .padding(5)
    }
}

