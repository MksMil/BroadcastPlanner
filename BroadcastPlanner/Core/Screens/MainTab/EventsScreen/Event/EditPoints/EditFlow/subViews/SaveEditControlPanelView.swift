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
        .onReceive(vm.$selectedVenuePoint) { selectedVenuePoint in
            withAnimation(.linear(duration: 0.1)) {
                isEdit = selectedVenuePoint == nil ? false : true
            }
        }
        .onReceive(vm.$selectedObvan) { selectedObvan in
            withAnimation(.linear(duration: 0.1)) {
                isEdit = selectedObvan == nil ? false : true
            }
        }

    }
}
