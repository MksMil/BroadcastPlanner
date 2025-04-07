import SwiftUI

struct LocationCell: View {
    
    let title: String
    let address: String
    
    init(title: String, address: String) {
        self.title = title
        self.address = address
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 2){
                Text("\(title)")
                    .font(.title3)
//                Divider()
                Text("\(address)")
                    .lineLimit(3)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        .padding(.vertical,8)
        .padding(.horizontal,12)
        .background {
            RoundedRectangle(cornerRadius: 5).fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    LocationCell(title: "DONBASS - ARENA", address: "Donetsk")
}
