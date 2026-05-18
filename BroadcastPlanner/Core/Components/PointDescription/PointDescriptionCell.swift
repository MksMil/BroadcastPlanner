import SwiftUI

struct PointDescriptionCell: View {

    let image: UIImage?
    let firstName: String?
    let lastName: String?
    let number: Int?
    let camera: String?
    let sound: String?
    let light: String?
    let unitDescription: String?
    

    private var numberText: String {
        guard let number else { return "questionmark.circle" }
        return "\(number).circle"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack(alignment: .bottom) {
                // фото
                Group {
                  if let image{
                    // TODO: may be circle crop for image?
                    Image(uiImage: image)
                      .resizable()
                      .scaledToFit()
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(.systemGray6))
                .clipped()

                // градиент + теги
                let tags = [(camera, "video.circle"), (sound, "mic.fill"), (light, "lightbulb.fill")]
                    .compactMap { val, icon -> (String, String)? in
                        guard let v = val, v != "Empty" else { return nil }
                        return (v, icon)
                    }

                if !tags.isEmpty {
//                    LinearGradient(
//                      colors: [.clear, Color.mainBack.opacity(0.75)],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )

                    FlowLayout(spacing: 3) {
                        ForEach(tags, id: \.0) { text, icon in
                            EquipTag(icon: icon, text: text)
                        }
                    }
                    
                    .padding(5)
                }
            }
            .compositingGroup()

          ZStack(alignment: .trailing) {
                 if let number {
                     Text("\(number)")
                         .font(.system(size: 38, weight: .bold))
                         .foregroundStyle(Color.black.opacity(0.2))
                         .lineLimit(1)
                         .padding(.trailing, 6)
                         .padding(.bottom, 2)
                 }

                 VStack(alignment: .leading, spacing: 1) {
                     Text(firstName ?? "")
                     Text(lastName ?? "")
                 }
                 .font(.system(size: 13, weight: .semibold))
                 .lineLimit(1)
                 .minimumScaleFactor(0.7)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .padding(.horizontal, 7)
                 .padding(.vertical, 5)
             }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        }
    }
}

private struct EquipTag: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .medium))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}

#Preview {
  ZStack {
    MainBackground()
    VStack {
      PointDescriptionCell(
        image: nil,
        firstName: "Aleksandr",
        lastName: "Skripnichenko",
        number: 1,
        camera: "stedicam",
        sound: "very strong mic dog",
        light: "super puper light",
        unitDescription: "main cam"
      )
      .frame(width: 200,height: 300)
    }
  }
}

