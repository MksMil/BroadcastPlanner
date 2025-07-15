import SwiftUI

struct VenueCell: View {
    
    let title: String
    let address: String
    let isSelected : Bool

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
        .scaleEffect(isSelected ? 1.05: 1)
        .opacity(isSelected ? 1 : 0.65)
    }
}

#Preview {
    VenueCell(title: "DONBASS - ARENA", address: "Donetsk",isSelected: true)
}
