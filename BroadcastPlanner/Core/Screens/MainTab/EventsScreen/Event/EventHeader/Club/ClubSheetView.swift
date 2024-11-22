import SwiftUI

struct ClubSheetView: View {
    @StateObject var vm: ClubSheetViewModel
    @Namespace var clubNS

    let cancelAction: ()->Void
    let acceptAction: (LocalClub)->Void
    let defineLocation: (LocalClub)->Void
    @FetchRequest<LocalClub>(sortDescriptors: []) var clubs
    
    init(cancelAction: @escaping () -> Void = {},
         acceptAction: @escaping (LocalClub) -> Void = {_ in },
         defineLocation: @escaping (LocalClub)->Void){
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
        self.defineLocation = defineLocation
        self._vm = StateObject(wrappedValue: ClubSheetViewModel())
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        if !vm.isEditState{
            VStack(spacing: 20){
                //header group
                ConfirmationButtonGroupView(height: 50, isAcceptDisabled: vm.isAcceptDissabled) {
                    cancelAction()
                } acceptAction: {
                    //accept club to selected point
                    guard let selectedClub = vm.selectedClub else { return }
                    acceptAction(selectedClub)
                } content: {
                    Button{
                        guard vm.selectedClub != nil else { return }
                        withAnimation{
                            vm.isEditState = true
                        }
                    } label: {
                        Text(vm.selectedClub == nil ? "Choose Club":vm.buttonTitle)
                            .lineLimit(2)
                            .frame(width: 250)
                            .frame(height: 50)
                            .font(.title3)
                            .background {
                                Rectangle()
                                    .fill(vm.selectedClub == nil ? .ultraThinMaterial:.ultraThickMaterial)
                                    .overlay {
                                        Rectangle()
                                            .stroke(Color.black.opacity(vm.selectedClub == nil ? 0.3: 1),
                                                    lineWidth: 1)
                                    }
                            }
                    }
                    .disabled(vm.isAcceptDissabled)
                }
                .disabled(vm.isEditState)
                .padding(.horizontal,10)
                .padding(.top, 10)
                .font(.title3)
                
                ScrollView{
                    LazyVStack{
                        SmartLayout(hSpacing: 5, vSpacing: 5) {
                            //add club button
                            Image(systemName: "plus.circle")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 75, height: 100)
                                .onTapGesture {
                                    vm.editWithNewClub()
                                }

                            ForEach(clubs){ club in
                                ClubSheetCellView(club: club)
                                .matchedGeometryEffect(id: club.id,
                                                       in: clubNS,
                                                       isSource: true)
                                .onTapGesture {
                                    withAnimation{
                                        vm.selectedClub = club
                                    }
                                }
                            }
                            .overlay {
                                if let selectedClub = vm.selectedClub{
                                    Rectangle()
                                        .stroke(.blue, lineWidth: 2)
                                        .matchedGeometryEffect(id: selectedClub.id,
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
                    withAnimation{
                        vm.selectedClub = nil
                    }
                }
            }
        } else {
            if let selectedClub = vm.selectedClub{
                AddEditClubView(club: selectedClub) { title, uiimage,contacts ,urlString, location in
                    vm.updateClubWith(title: title,
                                      uiimage: uiimage,
                                      contacts: contacts,
                                      urlString: urlString,
                                      location: location)
                } cancelAction: {
                    withAnimation{
                        vm.selectedClub = nil
                        vm.isEditState = false
                    }
                } removeAction: {
                    vm.removeSelectedClub()
                } defineLocation: { club in
                    defineLocation(club)
                }
            } else {
                // TODO: Error and return
                Text("Error: No club")
                    
            }
        }
    }
}

#Preview {
    ClubSheetView(
        cancelAction: {},
        acceptAction: {_ in },
        defineLocation: {_ in})
    .environment(\.managedObjectContext, DataManager.shared.moc)
}
