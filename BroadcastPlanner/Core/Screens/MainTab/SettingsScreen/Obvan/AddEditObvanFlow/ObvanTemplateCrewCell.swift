import SwiftUI

struct ObvanTemplateCrewCell: View {
    let crewPosition: String?
    let isSelected: Bool

    var body: some View {
        Text(crewPosition ?? "Unknown")
            .font(.system(size: 13, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.primary.opacity(0.4) : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            }
            .opacity(isSelected ? 1 : 0.7)
    }
}
