import SwiftUI

final class AddUnitFormViewModel: ObservableObject{
    @Published var selectedUser: LocalUser?
}

struct AddUnitFormView: View {
    @StateObject private var vm: AddUnitFormViewModel = AddUnitFormViewModel()
    
    let availableUsers: [LocalUser]
    let cancelAction: ()->()
    let addAction: (UserSpecialization, LocalUser,ReplayType?)->()
    @State private var selectedSpecialization: UserSpecialization?
    @State private var selectedHardware: ReplayType?
//    @State private var selectedUser: LocalUser?
    
    @State private var isShowInfo: Bool = false
    @State private var userForInfo: LocalUser?
    var isAcceptAvailable: Bool {
        guard vm.selectedUser != nil else { return false}
        guard selectedSpecialization != nil else { return false}
        
        return true
    }
    
    private var filteredUsers: [LocalUser] {
        guard let selectedSpecialization else { return availableUsers }
        return availableUsers.filter { user in
            user.userSpecialization.contains{$0 == selectedSpecialization}
        }
    }
    var body: some View {
        VStack{
            Text("Add Unit form here")
            //data for new obvanUnit -> out
            //position, user , hardware?
            Spacer()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            
            SmartLayout(hSpacing: 15, vSpacing: 15){
                ForEach(UserSpecialization.obvanSpecialization){ specialization in
                    AddUnitFormCell(text: specialization.rawValue,
                                    state: stateForCell(spec: specialization))
                        .onTapGesture {
                            withAnimation{
                                if selectedSpecialization == specialization{
                                    selectedSpecialization = nil
                                    selectedHardware = nil
                                } else {
                                    selectedSpecialization = specialization
                                    if specialization != .replayOperator {
                                        selectedHardware = nil
                                    }
                                }
                            }
                        }
                }
            }
            if let selectedSpecialization,
               selectedSpecialization == .replayOperator{
                VStack{
                    Text("Replay Hardware")
                        .font(.title3)
                        .foregroundStyle(.white)
                    SmartLayout(hSpacing: 5, vSpacing: 5){
                        ForEach(ReplayType.withoutEmpty){ replay in
                            Text(replay.rawValue)
                                .font(.callout)
                                .foregroundStyle(.black)
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 5).fill(.white)
                                }
                                .opacity(replay == selectedHardware ? 1 : 0.5)
                                .onTapGesture {
                                    withAnimation{
                                        if selectedHardware == replay{
                                            selectedHardware = nil
                                        } else {
                                            selectedHardware = replay
                                        }
                                    }
                                }
                        }
                    }
                }
                .padding(.top, 15)
            }
            
            List{
                ForEach(filteredUsers){ user in
                    AddUnitFormUserCell(user: user){
                        userForInfo = user
                        isShowInfo = true
                    }
                    .onTapGesture {
                        withAnimation{
                            if vm.selectedUser == user{
                                vm.selectedUser = nil
                            } else {
                                vm.selectedUser = user
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            Spacer()
            HStack{
                Button("Cancel"){
                    cancelAction()
                }
                .buttonStyle(.borderedProminent)
                Button("Accept"){
                    if let selectedUser = vm.selectedUser,
                       let selectedSpecialization = selectedSpecialization{
                        addAction(selectedSpecialization,selectedUser,selectedHardware)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isAcceptAvailable)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(Color.white)
        .sheet(item: $userForInfo) {
            userForInfo = nil
        } content: { user in
            
            BPUserProfileView(user: user)
        }

    }
    func stateForCell(spec: UserSpecialization)->AddUnitFormCell.AddUnitFormState{
        if let selectedSpecialization {
            return selectedSpecialization == spec ? .selected:.unselected
        } else {
            return .noSelection
        }
    }
}
