import SwiftUI

final class NetworkTestViewModel: ObservableObject{

    var selectedEvent: Broadcast?
    var selectedClub: Club?
    
    var id: String {
//        UUID().uuidString
        "user-id-\(Int.random(in: 1...20))"
    }
    var name: String {
        ["Bob","John","Donald","Vladimir"].randomElement()!
    }
    
}

struct NetworkTestView: View {
    @StateObject private var vm = NetworkTestViewModel()
    @EnvironmentObject var mdm: MainDataManager
    
    var body: some View {
        ZStack{
            MainBackground()
            VStack{
                //member section for test: create + , update +
                Section {
                    Button("Create User") {
                        Task{
                            await mdm.createUser(id: vm.id)
                        }
                    }
                    Button("Update User") {
                        Task{
                            await mdm.updateUserData(firstName: vm.name,
                                                     lastName: "",
                                                     email: "",
                                                     phoneNumber: "",
                                                     address: "",
                                                     userSpecialization: [],
                                                     inputImage: nil)
                        }
                    }
                } header: {
                    Text("User")
                        .font(.title)
                }
                //broadcast section : create +, update +, remove +
                Section {
                    Button("Create Broadcast"){
                        Task{
                            vm.selectedEvent = try? await  mdm.createEventWithCurrentUserOwnerInContextType()
                        }
                    }
                    
                    Button("Update Broadcast"){
                        if let event = vm.selectedEvent{
                            Task{ await mdm.updateEvent(event,
                                                      homeClub: nil,
                                                      guestClub: nil,
                                                      eventDate: .now,
                                                      location: nil) }
                        }
                    }
                    
                    Button("Remove Broadcast"){
                        if let event = vm.selectedEvent{
                            Task{
                                await mdm.removeEvent(event: event)
                                vm.selectedEvent = nil
                            }
                        }
                    }
                } header: {
                    Text("Event")
                }
                //club section : create +, update +, remove +
                Section {
                    Button("Create Club") {
                        vm.selectedClub = mdm.createClub()
                    }
                    Button("Update Club"){
                        
                        if let club = vm.selectedClub{
                            Task{
                                await mdm.updateClub(club, withTitle: "newTitle", uiimage: GlobalProperties.randomClubImage, contacts: "", urlString: "", location: nil, inContext: .main)
                            }
                        }
                    }
                    
                    Button("RemoveClub"){
                        if let club = vm.selectedClub{
                            Task{
                                await mdm.removeCub(club)
                                vm.selectedClub = nil
                            }
                        }
                    }
                } header: {
                    Text("Club")
                }
                //venue section:
                Section {
                    Button("Create Venue"){
                        
                    }
                } header: {
                    Text("Venue")
                }




                
                
                
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    Home(localDataManager: DataManager(),
         globalDataManager: NetworkManager(),
         userId: "123")
        .environmentObject(GlobalSettings())
        .environmentObject(SessionManager())
        .environmentObject(ApplicationState())
}
