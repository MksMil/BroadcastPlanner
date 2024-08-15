import SwiftUI

struct StadiumView: View {
    
    var imageName: String = "football_stadium"
    
    var body: some View {
        
        HStack(spacing: 0){
                Image(imageName)
                    .resizable()
        }
    }
}

struct CarView: View {
    
    var imageName: String = "OBVAN_v1"
    
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 100,height: 300)
            .rotationEffect(.degrees(90))
            .frame(width: 300,height: 100)
    }
}

#Preview {
//    StadiumView()
    CarView()
    
}

