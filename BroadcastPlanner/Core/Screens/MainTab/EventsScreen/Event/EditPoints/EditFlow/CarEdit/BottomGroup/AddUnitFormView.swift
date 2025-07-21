import SwiftUI

final class AddUnitFormViewModel: ObservableObject{
    @Published var selectedUser: Member?
}

struct AddUnitFormView: View {
    @EnvironmentObject var settings: GlobalSettings
    
    @StateObject private var vm: AddUnitFormViewModel = AddUnitFormViewModel()
    
    let availableUsers: [Member]
    let cancelAction: ()->()
    let addAction: (String, Member,String?)->()
    
    @State private var selectedSpecialization: String?
    @State private var selectedHardware: String?
//    @State private var selectedUser: Member?
    
    @State private var isShowInfo: Bool = false
    @State private var userForInfo: Member?
    
    var isAcceptAvailable: Bool {
        guard vm.selectedUser != nil else { return false}
        guard selectedSpecialization != nil else { return false}
        
        return true
    }
    
    private var filteredUsers: [Member] {
        guard let selectedSpecialization else { return availableUsers }
        return availableUsers.filter { user in
            user.viewSpecialization.contains{$0 == selectedSpecialization}
        }
    }
    var body: some View {
        VStack{
            Text("Add Crew form here")
            //data for new crew -> out
            //position, member , hardware?
            Spacer()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            
            SmartLayout(hSpacing: 15, vSpacing: 15){
                ForEach(settings.userSpecialization,id: \.self){ specialization in
                    AddUnitFormCell(text: specialization,
                                    state: stateForCell(spec: specialization))
                        .onTapGesture {
                            withAnimation{
                                if selectedSpecialization == specialization{
                                    selectedSpecialization = nil
                                    selectedHardware = nil
                                } else {
                                    selectedSpecialization = specialization
                                    if specialization != "Replay operator" {
                                        selectedHardware = nil
                                    }
                                }
                            }
                        }
                }
            }
            if let selectedSpecialization,
               selectedSpecialization == "Replay operator"{
                VStack{
                    Text("Replay Hardware")
                        .font(.title3)
                        .foregroundStyle(.white)
                    SmartLayout(hSpacing: 5, vSpacing: 5){
                        ForEach(settings.hardwareType, id:\.self){ replay in
                            Text(replay)
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
    func stateForCell(spec: String)->AddUnitFormCell.AddUnitFormState{
        if let selectedSpecialization {
            return selectedSpecialization == spec ? .selected:.unselected
        } else {
            return .noSelection
        }
    }
}
