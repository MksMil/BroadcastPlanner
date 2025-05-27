import Combine
import SwiftUI

struct SaveEditControlPanelView: View {
    @EnvironmentObject var vm: BPEditStadiumViewModel
    //Actions
    let addAction: () -> Void
    let deleteAction: () -> Void
    let saveAction: () -> Void
    let editAction: () -> Void

    @State private var isEdit: Bool = false
    @State private var isDelete: Bool = false

    var body: some View {
        HStack {
            Button(
                action: {
                    isDelete = true
                },
                label: {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding(10)
                        .frame(width: 40, height: 40)
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
                        .opacity(isEdit ? 1 : 0.3)
                }
            )
            .disabled(!isEdit)
            Spacer()
            Button(
                action: {
                  editAction()
                },
                label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding(10)
                        .frame(width: 40, height: 40)
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
                        .opacity(isEdit ? 1 : 0.3)
                }
            )
            .disabled(!isEdit)
            Spacer()
            
            Button(
                action: {
                    if isEdit {
                        saveAction()
                    } else {
                        addAction()
                    }
                },
                label: {
                    Image(systemName: isEdit ? "checkmark" : "plus")
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .padding(10)
                        .frame(width: 40, height: 40)
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
                }
            )
        }
        .font(.callout)
        .foregroundStyle(.black)
        .bold()
        .lineLimit(1)
        .minimumScaleFactor(0.2)
        .confirmationDialog("", isPresented: $isDelete) {
            Button("Delete Point", role: .destructive) {
                withAnimation {
                    deleteAction()
                }

            }
        }
        .onReceive(vm.$selectedEventPoint) { selectedEventPoint in
            withAnimation(.linear(duration: 0.1)) {
                isEdit = selectedEventPoint == nil ? false : true
            }
        }

    }
}

//#Preview {
//    SaveEditControlPanelView(addAction: {}, deleteAction: {}, saveAction: {}, isEditAction: {}, isEdit: false)
//}
#Preview {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(
        localDataManager: lm,
        globalDataManager: NetworkManager(),
        userId: "123"
    )
    let localEvent = lm.fetchOrCreateObject(
        ofType: Broadcast.self,
        predicate: NSPredicate(format: "id == %@", "id"),
        in: lm.mainContext
    ) { ctx in
        let newEvent = Broadcast(context: ctx)
        newEvent.id = "id"
        return newEvent
    }
    return BPEditStadiumView(event: localEvent)
        .environmentObject(mdm)
        .environment(\.managedObjectContext, mdm.localDataManager.mainContext)
}
