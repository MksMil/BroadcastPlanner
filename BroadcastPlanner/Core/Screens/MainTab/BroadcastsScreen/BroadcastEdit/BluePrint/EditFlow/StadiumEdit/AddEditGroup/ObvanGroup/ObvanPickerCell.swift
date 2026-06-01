import SwiftUI

struct ObvanPickerCell: View {
    let obvanName: String
    let obvanBroadcaster: String
    let image: UIImage?

    var body: some View {
        HStack(spacing: 10) {
            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "bus")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 44, height: 44)
            .background(Color.primary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(obvanName)
                    .font(.system(size: 14, weight: .medium))
                Text(obvanBroadcaster)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        }
    }
}
