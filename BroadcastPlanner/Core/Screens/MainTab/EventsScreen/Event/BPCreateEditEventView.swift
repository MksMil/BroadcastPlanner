import SwiftUI
import Combine

struct BPCreateEditEventView: View {
    
    @EnvironmentObject var globalStorage: GlobalStorage
    @EnvironmentObject var eventRouter: EventTabRouter
    @StateObject var editManager: EditPlanPointsManager = EditPlanPointsManager()
    
    @State var event: Event
    
    @State private var type: PlanSectionType?
    var editable: Bool {
        event.owners.contains { $0 == globalStorage.id }
    }
    
    var listUsers: [String: UIImage?] {
        var result = [String: UIImage?]()
        for user in globalStorage.users{
            guard let id = user.id else { continue }
            result[user.fullCompactName] = globalStorage.usersImages[id]
        }
        return result
    }
    
    var layoutList: [String] {
        listUsers.keys.map{$0}.sorted(by: <)
    }
    
    var body: some View {
        
            ZStack(){
                MainBackground()
                
                VStack(alignment: .leading, spacing: 0){
                    BPEventHeaderView(event: $event)
                        .frame(height: 300)
                        .disabled(!editable)
                    
                    GeometryReader{ geo in
                        BPEditEventPointLinks(event: event){
                            editManager.renderScene.type = .stadium
                            type = .stadium
                        } actionRight: {
                            editManager.renderScene.type = .car
                            type = .car
                        }
                        .frame(height: geo.size.width / 2)
                    }
                    .padding(.horizontal)
                    //staff list
//                    EventUsersGridView(users: users,
//                                       images: globalStorage.usersImages)
                    // TODO: (struct: Hashable, id: comb(name+num)) for the grid !?!
                    ScrollView{
                        SmartLayout(hSpacing: 5, vSpacing: 5){
                            ForEach(layoutList, id: \.self){ user in
                                if let image = listUsers[user]{
                                    BPUserDataListCellView(text: user,
                                                           image: image)
                                } else {
                                    BPUserDataListCellView(text: user)
                                }
                            }
                        }
                    }
                    .padding(.horizontal,10)
                    Spacer()
                }
            }
            .fullScreenCover(item: $type) { type in
                BPEditConteinerView(event: $event, 
                                    type: type,
                                    editable: editable )
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
                            await  globalStorage.updateEvent(event)
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
                            globalStorage.removeEvent(event)
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
        BPCreateEditEventView( event: MockData.sampleEvent)
    }
        .environmentObject(GlobalSettings())
        .environmentObject(GlobalStorage())
        .environmentObject(EventTabRouter())
        .environmentObject(GlobalTimer())
}
