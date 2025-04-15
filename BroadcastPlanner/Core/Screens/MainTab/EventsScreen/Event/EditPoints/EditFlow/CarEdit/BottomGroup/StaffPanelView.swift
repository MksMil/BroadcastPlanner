import SwiftUI

struct StaffPanelView: View {
    let event: LocalEvent

    @FetchRequest<LocalUser>(sortDescriptors: []) var users
    var availableUsers: [LocalUser] {
        users.filter{$0.isAvailableToEvent(event: event)}
    }
        
    let addUnitAction: (LocalUser, UserSpecialization, ReplayType?)->()
    let removeUnitAction: (LocalUnit)->()
    let editUnitAction: ()->()
    
    @State private var isAddUnit: Bool = false
    
    init(event: LocalEvent,
         addUnitAction: @escaping (LocalUser, UserSpecialization, ReplayType?) -> Void,
         removeUnitAction: @escaping (LocalUnit) -> Void,
         editUnitAction: @escaping () -> Void) {
        self.event = event
        self.addUnitAction = addUnitAction
        self.removeUnitAction = removeUnitAction
        self.editUnitAction = editUnitAction
    }
    
    var body: some View {
        VStack{
            Button("Add new unit"){
                isAddUnit = true
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white.opacity(0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.white.opacity(0.4),
                                    lineWidth: 2)
                    }
            }
            .padding(8)
            List{
                ForEach(event.viewObvanUnits){ unit in
                    StaffPanelCellView(unit: unit)
                        .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    let unitToRemove = event.viewObvanUnits[index]
                    removeUnitAction(unitToRemove)
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.inset)
        }
        .frame(maxWidth: .infinity)
        .fullScreenCover(isPresented: $isAddUnit) {
            AddUnitFormView(availableUsers: availableUsers){
                isAddUnit = false
            } addAction: {specialization, localUser, hardware in
                isAddUnit = false
                addUnitAction(localUser, specialization, hardware)
            }
            .presentationBackground(Color.black.opacity(0.8))
        }
    }
}

struct StaffPanelCellView: View {
    
    let unit: LocalUnit
    
    var body: some View {
        HStack{
            unit.user?.userImage
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(content: {
                    Circle().stroke(Color.white, lineWidth: 2)
                })
                .frame(width:30, height: 30)
            VStack(alignment: .leading){
                if let user = unit.user{
                    Text(user.userCompactName)
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.6)
                } else {
                    Text("---")
                        .font(.system(size: 14))
                        .minimumScaleFactor(0.6)
                }
                    
                Text(unit.viewPosition.rawValue)
                    .font(.system(size: 11))
                    .minimumScaleFactor(0.6)
            }
        }
    }
}

//#Preview(body: {
//    AddUnitFormView(availableUsers: []){
//        
//    } addAction: { _,_,_ in
//        
//    }
//})

#Preview(body: {
    let lm = DataManager(forPreview: true)
    let mdm = MainDataManager(localDataManager: lm,
                              globalDataManager: NetworkManager(),
                              userId: "123")
    let localEvent = lm.fetchOrCreateObject(ofType: LocalEvent.self,
                  predicate: NSPredicate(format: "id == %@", "id"),
                                      in: lm.moc) {
        let newEvent = LocalEvent(context: lm.moc)
        newEvent.id = "id"
        return newEvent
    }
    return StaffPanelView(event:localEvent) { _, _, _ in
        
    } removeUnitAction: { _ in
        
    } editUnitAction: {
        
    }

})
