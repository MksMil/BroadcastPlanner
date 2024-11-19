import SwiftUI
//import UIKit

struct ClubSheetView: View {
    @StateObject var vm: ClubSheetViewModel
    @Namespace var clubNS
    
    let cancelAction: ()->Void
    let acceptAction: (LocalClub)->Void
    let createNewClubAction: ()->Void
    let editClubAction: (LocalClub)->Void
    
    var buttonTitle: String {
        guard let selectedClub = vm.selectedClub else {return "Choose Club" }
        return "Edit \(selectedClub.viewTitle)"
    }
    
    @FetchRequest<LocalClub>(sortDescriptors: []) var clubs
    
    init(cancelAction: @escaping () -> Void = {},
         acceptAction: @escaping (LocalClub) -> Void = {_ in },
         createNewClubAction: @escaping () -> Void = {},
         editClubAction: @escaping (LocalClub) -> Void = {_ in }){
        self.cancelAction = cancelAction
        self.acceptAction = acceptAction
        self.createNewClubAction = createNewClubAction
        self.editClubAction = editClubAction
        self._vm = StateObject(wrappedValue: ClubSheetViewModel())
    }
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges()
#endif
        if !vm.isEditState{
            VStack(spacing: 20){
                HStack{
                    Button {
                        cancelAction()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .padding()
                            .background {
                                Rectangle()
                                    .fill(.red.opacity(0.3))
                                    .overlay {
                                        Rectangle()
                                            .stroke(Color
                                                .red
                                                .opacity(0.5),
                                                    lineWidth: 2)
                                    }
                            }
                            .frame(width: 50)
                    }
                    
                    Spacer()
                    //     edit club button
                    Button{
                        guard vm.selectedClub != nil else { return }
                        withAnimation{
                            vm.isEditState = true
                        }
                    } label: {
                        Text(vm.selectedClub == nil ? "Choose Club":buttonTitle)
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
                    .disabled(vm.selectedClub == nil)
                    
                    Button{
                        //accept club to selected point
                        guard let selectedClub = vm.selectedClub else { return }
                        acceptAction(selectedClub)
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .bold()
                            .padding()
                            .background {
                                Rectangle().fill(vm.selectedClub == nil ? .gray.opacity(0.3): .green.opacity(0.3))
                                    .overlay {
                                        Rectangle().stroke(vm.selectedClub == nil ? Color.gray.opacity(0.5):Color.green.opacity(0.5),
                                                           lineWidth: 2)
                                    }
                            }
                            .frame(width: 50)
                    }
                    .disabled(vm.selectedClub == nil)
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
                                    vm.selectedClub = club
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
                    vm.updateClubWith(title: title, uiimage: uiimage, contacts: contacts, urlString: urlString, location: location)
                } cancelAction: {
                    withAnimation{
                        vm.selectedClub = nil
                        vm.isEditState = false
                    }
                } removeAction: {
                    vm.removeSelectedClub()
                }
            }
        }
    }
}

#Preview {
    ClubSheetView(
        cancelAction: {},
        acceptAction: {_ in },
        createNewClubAction: {},
        editClubAction: {_ in })
    .environment(\.managedObjectContext, DataManager.shared.moc)
}
