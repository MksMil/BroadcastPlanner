import SwiftUI

struct ClubSheetView: View {
    @EnvironmentObject var mdm: MainDataManager
    @StateObject var vm: ClubSheetViewModel
    @Namespace var clubNS
    //    @State private var isEdit: Bool = false

    let editMode: Bool

    let cancelAction: () -> Void
    let acceptAction: (LocalClub) -> Void
    let addEditAction: (LocalClub) -> Void

    @FetchRequest<LocalClub>(sortDescriptors: [], animation: .easeInOut)
    var clubs

    init(
        editMode: Bool = false,
        cancelAction: @escaping () -> Void = {},
        acceptAction: @escaping (LocalClub) -> Void = { _ in },
        addEditAction: @escaping (LocalClub) -> Void
    ) {
        self.editMode = editMode
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
        self.addEditAction = addEditAction
        self._vm = StateObject(wrappedValue: ClubSheetViewModel())
    }

    var body: some View {

        ZStack {
            MainBackground()
            VStack(spacing: 20) {
                //header group
                ConfirmationButtonGroupView(
                    height: 50,
                    isAcceptDisabled: vm.isAcceptDissabled
                ) {
                    cancelAction()
                } acceptAction: {
                    //accept club to selected point
                    guard let selectedClub = vm.selectedClub else { return }
                    acceptAction(selectedClub)
                } content: {
                    Text(
                        editMode
                            ? (vm.isAcceptDissabled ? "Add" : "Edit")
                            : (vm.selectedClub == nil
                                ? "Choose Club" : vm.buttonTitle)
                    )
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .font(.title3)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.4))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        Color.black.opacity(
                                            vm.selectedClub == nil ? 0.5 : 1),
                                        lineWidth: 1)
                            }
                    }
                    .onTapGesture {
                        if editMode {
                            addEditAction(vm.selectedClub ?? mdm.getNewClub())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .font(.title3)
                ScrollView {
                    VStack {
                        SmartLayout(hSpacing: 5, vSpacing: 5) {
                            ForEach(clubs) { club in
                                ClubSheetCellView(club: club)
                                    .matchedGeometryEffect(
                                        id: club.id,
                                        in: clubNS,
                                        isSource: true
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            if vm.selectedClub == club {
                                                //                                            isEdit = false
                                                vm.selectedClub = nil
                                            } else {
                                                //                                            isEdit = true
                                                vm.selectedClub = club
                                            }
                                        }
                                    }
                            }
                            .overlay {
                                if let selectedClub = vm.selectedClub {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(.blue, lineWidth: 2)
                                        .matchedGeometryEffect(
                                            id: selectedClub.id,
                                            in: clubNS,
                                            isSource: false)
                                }
                            }
                        }

                    }
                    .padding(.horizontal, 15)
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                }
                .onTapGesture {
                    withAnimation {
                        vm.selectedClub = nil
                    }
                }
            }
        }
        .onReceive(
            mdm.localDataManager.updatePublisher,
            perform: { value in
                if value.0 == .clubs {
                    if value.1.isEmpty {
                        vm.selectedClub = nil
                    } else {
                        vm.selectedClub?.objectWillChange.send()
                    }
                }
            }
        )
        .navigationBarBackButtonHidden()
    }
}

//#Preview {
//    ClubSheetView(
//        editMode: true,
//        cancelAction: {},
//        acceptAction: { _ in },
//        addEditAction: { _ in })
//    //    .environment(\.managedObjectContext, DataManager.shared.moc)
//}
