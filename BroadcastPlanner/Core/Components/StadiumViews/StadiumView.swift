import SwiftUI

struct StadiumView: View {
    
    var fieldImageName: String = "football_stadium"
    var carImageName: String = "OBVAN_v1"
    
    var body: some View {
        
        HStack(spacing: 0){
                Image(fieldImageName)
                    .resizable()

                Image(carImageName)
                    .resizable()
                    .aspectRatio(0.35, contentMode: .fit)
        }
    }
}

#Preview {
    StadiumView()
    
}


