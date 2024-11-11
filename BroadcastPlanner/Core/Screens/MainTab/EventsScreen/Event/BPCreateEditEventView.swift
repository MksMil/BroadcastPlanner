import SwiftUI
import SpriteKit
import Combine

enum PlanSectionType: String, Identifiable {
    case stadium
    case car
    var id: Self { self }
}

struct BPCreateEditEventView: View {
    
    @EnvironmentObject var eventRouter: EventTabRouter
    
    @StateObject var editManager: EditPlanPointsManager = EditPlanPointsManager()
    
    @State var event: LocalEvent
    
    @State private var type: PlanSectionType?
    var editable: Bool {
//        event.owners.contains { $0 == globalStorage.id }
        true
    }
    
    @FetchRequest<LocalUser>(sortDescriptors: []) private var users
    //coredata fetchrequest here
//    var listUsers: [String: UIImage?] {
//        var result = [String: UIImage?]()
//        for user in globalStorage.users{
//            guard let id = user.id else { continue }
//            result[user.fullCompactName] = globalStorage.usersImages[id]
//        }
//        return result
//    }
    
//    var layoutList: [String] {
//        listUsers.keys.map{$0}.sorted(by: <)
//    }
    
    var body: some View {
        
            ZStack(){
                MainBackground()
                
                VStack(alignment: .center, spacing: 0){
                    //header: time, date, teams, location
                    BPEventHeaderView(event: event, routeAction:{
                        eventRouter.routeStepBack()
                    })
                        .frame(height: 300)
                        .disabled(!editable)
                        .frame(maxWidth: .infinity)
                    
                    
                    //preview + fsc editStad / editCar  views
                    GeometryReader{ geo in
                        HStack(spacing: 15){
                            SpriteView(scene: editManager.previewStadium)
                                .frame(width: 3 * geo.size.width / 4)
                                .onTapGesture {
                                    type = .stadium
                                }
                            
                            SpriteView(scene: editManager.previewCar)
                                .onTapGesture {
                                    type = .car
                                }
                        }
                        .frame(height: geo.size.width / 2)
                        .padding(.horizontal)
                    }
                   
                    
                    //staff list
//                    EventUsersGridView(users: users,
//                                       images: globalStorage.usersImages)
                    // TODO: (struct: Hashable, id: comb(name+num)) for the grid !?!
                    ScrollView{
//                        SmartLayout(hSpacing: 5, vSpacing: 5){
//                            ForEach(users){ user in
////                                if let image = listUsers[user]{
////                                    BPUserDataListCellView(text: user,
////                                                           image: image)
////                                } else {
//                                BPUserDataListCellView(user: user, text: "text")
////                                }
//                            }
//                        }
                    }
                    .padding(.horizontal,10)
                    Spacer()
                }
            }
            .fullScreenCover(item: $type) { type in
               
                switch type {
                    case .stadium:
                        BPEditStadiumView(event: $event,
                                        editable: editable )
                    case .car:
                        BPEditCarView(event: $event,
                                      editable: editable)
                }
                
            }
            .navigationTitle("Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(editable)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                                if editable{
                ToolbarItem(placement: .confirmationAction) {
                    Button{
                        Task{
//                            await  globalStorage.updateEvent(event)
                            eventRouter.routeStepBack()
                        }
                    }label: {
                        Image(systemName: "checkmark.circle")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    // TODO: Delete Confirmation (Alert?)
                    Button{
                        Task{
//                            globalStorage.removeEvent(event)
                            eventRouter.routeStepBack()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
            .onAppear{
                editManager.configureWith(event: event)
            }
            .environmentObject(editManager)
    }
}

#Preview {
    NavigationStack{
        BPCreateEditEventView(event: LocalEvent(context: DataManager.shared.moc))
    }
        .environmentObject(GlobalSessionStorage())
        .environmentObject(GlobalSettings())
        .environmentObject(EventTabRouter())
        .environment(\.managedObjectContext, DataManager.shared.moc)
}
