import SwiftUI

@MainActor
class ObvanPickerViewModel: ObservableObject {
    @Published var images: [String: UIImage] = [:] // obvanId → UIImage
    
    let obvans: [Obvan]
    let alreadyAdded: [Obvan]
    private let dataManager: DataManager
    
    var available: [Obvan] {
        obvans.filter { obvan in
            !alreadyAdded.contains(where: { $0.id == obvan.id })
        }
    }
    
    init(obvans: [Obvan], alreadyAdded: [Obvan], dataManager: DataManager) {
        self.obvans = obvans
        self.alreadyAdded = alreadyAdded
        self.dataManager = dataManager
    }
    
    func loadImages() async {
        for obvan in available {
            guard !obvan.viewImageId.isEmpty else { continue }
            let image = await dataManager.getImageWithId(
                obvan.viewImageId,
                type: .obvan,
                size: .smallImages
            )
            if let image {
                images[obvan.viewId] = image
            }
        }
    }
}

struct ObvanPickerSheet: View {
    @StateObject var vm: ObvanPickerViewModel
    let onSelect: (Obvan) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            MainBackground()
            VStack(spacing: 0) {
                Text("выбери обван")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vm.available) { obvan in
                            ObvanPickerCell(
                                obvan: obvan,
                                image: vm.images[obvan.viewId]
                            )
                            .onTapGesture {
                                onSelect(obvan)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
                }
            }
        }
        .task { await vm.loadImages() }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground { MainBackground() }
    }
}

private struct ObvanPickerCell: View {
    let obvan: Obvan
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
                Text(obvan.viewName)
                    .font(.system(size: 14, weight: .medium))
                Text(obvan.viewBroadcasterName)
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
