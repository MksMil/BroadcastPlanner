import SwiftUI

struct SpecializationCellView: View {
    
    let cellWidth: Double
    let cellHeight: Double = 30
    let text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5).fill(.thinMaterial)
            .overlay {
                Text(text)
                    .font(.system(size: 12))
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal,8)
                    .padding(.vertical,4)
            }
            .frame(width: cellWidth, height: cellHeight)
        
    }
}

#Preview {
    SpecializationCellView(cellWidth: 50,text: "Hello")
        

}
