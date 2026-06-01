import SwiftUI

struct ObvanPositionPickerSheet: View {
    let positions: [String]
    let selected: String?
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing: 0) {
                Text("выбери позицию")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                FlowLayout(spacing: 8) {
                    ForEach(positions, id: \.self) { position in
                        let isSelected = position == selected
                        Text(position)
                            .font(.system(size: 13, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isSelected
                                    ? Color.white.opacity(0.7)
                                    : Color.white.opacity(0.2),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        isSelected
                                            ? Color.primary.opacity(0.4)
                                            : Color.white.opacity(0.4),
                                        lineWidth: isSelected ? 2 : 0.5
                                    )
                            }
                            .onTapGesture {
                                onSelect(position)
                                dismiss()
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground { MainBackground() }
    }
}
