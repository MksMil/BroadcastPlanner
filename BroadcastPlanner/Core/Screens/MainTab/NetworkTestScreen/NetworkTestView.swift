import SwiftUI

final class NetworkTestViewModel: ObservableObject{

    var selectedEvent: LocalEvent?
    var selectedClub: LocalClub?
    
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
                //user section for test: create + , update +
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
                //event section : create +, update +, remove +
                Section {
                    Button("Create Event"){
                        vm.selectedEvent = mdm.createEventWithCurrentUserOwnerInContextType(.main)
                    }
                    
                    Button("Update Event"){
                        if let event = vm.selectedEvent{
                            Task{ await mdm.updateEvent(event,
                                                      homeClub: nil,
                                                      guestClub: nil,
                                                      eventDate: .now,
                                                      location: nil) }
                        }
                    }
                    
                    Button("Remove Event"){
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
                //location section:
                Section {
                    Button("Create Location"){
                        
                    }
                } header: {
                    Text("Location")
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
