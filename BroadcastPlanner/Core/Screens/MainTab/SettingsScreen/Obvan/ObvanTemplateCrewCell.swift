
import SwiftUI

struct ObvanTemplateCrewCell: View {
    let crewPosition: String
    let isSelected: Bool
    
    var body: some View {
        
        Text(crewPosition)
            .padding(.vertical,3)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        .ultraThickMaterial
                            .opacity(0.3)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(
                                .ultraThickMaterial
                                    .opacity(0.5),
                                lineWidth: 2
                            )
                    }
            }
            .opacity(isSelected ? 1: 0.6)
    }
}
