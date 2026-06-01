import SwiftUI

struct ObvanPickerSheetView: View {
    @StateObject var vm: ObvanPickerSheetViewModel
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
                              obvanName: obvan.viewName,
                              obvanBroadcaster: obvan.viewBroadcasterName,
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


