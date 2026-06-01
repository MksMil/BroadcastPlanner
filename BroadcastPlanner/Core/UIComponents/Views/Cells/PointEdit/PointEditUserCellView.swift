import SwiftUI

struct PointEditUserCellView: View {
    let name: String
    let id: String
    
    var body: some View {
            VStack(spacing: 5){
                LogoInWhiteCircleView(id: id)
                
                Text(name)
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .frame(height: 20)
            }
            .padding(5)
    }
}

