import SwiftUI
import Combine

struct PointEditUserCellView: View {
    
    let user: LocalUser
    
    var body: some View {
            VStack(spacing: 5){
                user.viewImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                Text(user.viewCompactName)
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            }
            .padding(5)
    }
}

